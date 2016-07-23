---
layout: post
title:  "Nancy - Minifying HTML with WebMarkupMin"
date:   2016-07-23 15:00:00 +1000
categories:
---
I've been working with Nancy <http://nancyfx.org/> for about a year, a great open-source project that I use primarily to add simple and low-overhead REST APIs to ASP.NET web forms projects.

Nancy routes that return HTML can benefit from minifying - a process which removes comments and whitespace, reducing the amount of data transmitted from server to the browser. To do the actual minifying, I used WebMarkupMin <https://github.com/Taritsyn/WebMarkupMin> which can be downloaded from NuGet at <https://www.nuget.org/packages/WebMarkupMin.Core>.

My minification code below assumes Nancy, WebMarkupMin & WebMarkupMin Web Extensions are installed in the project (including the relevant configuration in `web.config`) - follow directions on the respective sites to get them working in your environment. I developed the code in Visual Studio 2015 Update 2 on Windows with Nancy 1.4.2 and WebMarkupMin version 0.9.2.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

First I created a new class called "NancyBootstrapperEx" that inherits from `DefaultNancyBootstrapper`; if you already have a Nancy bootstrapper, you should be able to add the code in as you can only have one bootstrapper. From the Nancy docs at <https://github.com/NancyFx/Nancy/wiki/Bootstrapper>:

> When the application starts up, Nancy looks for a custom bootstrapper. By default, it scans all assemblies with a reference to Nancy. If it doesn't find one, it'll fall back to the DefaultNancyBootstrapper. You can only have one bootstrapper per application. If more than one custom bootstrapper is found in your application, Nancy tries to be smart and checks if one inherits from the other. When that is the case Nancy chooses the most derived bootstrapper.

Based on Simon Cropp's article "HTTP Compression with NancyFX" at <http://simoncropp.com/httpcompressionwithnancyfx>, I overrode the `ApplicationStartup` method to add an `AfterRequest` handler to check for HTML content, and minify. My language of choice is VB.NET, however the concept will work for C# too:

{% highlight vb %}
Option Strict Off
Option Explicit On

#Region " Imports "
Imports Nancy
Imports Nancy.Bootstrapper
Imports Nancy.TinyIoc
Imports System.IO
#End Region

''' <summary>
''' Override application start and add a method to minify HTML responses from Nancy, at the end of the pipeline.
''' Written by Thomas Williams at https://thomasswilliams.github.io, shared with CC BY 4 license. This bootstrapper
''' will be picked up by default by Nancy as per docs:
'''   "When the application starts up, Nancy looks for a custom bootstrapper. By default, it scans all assemblies
'''    with a reference to Nancy. If it doesn't find one, it'll fall back to the DefaultNancyBootstrapper."
''' </summary>
Public Class NancyBootstrapperEx
  Inherits DefaultNancyBootstrapper

  ''' <summary>
  ''' On application startup, add a handler after requests, to minify HTML content. Adapted from
  ''' http://simoncropp.com/httpcompressionwithnancyfx,
  ''' https://yobriefca.se/blog/2011/11/01/nancy-jsonp-hook/.
  ''' </summary>
  Protected Overrides Sub ApplicationStartup(container As TinyIoCContainer, pipelines As IPipelines)
    MyBase.ApplicationStartup(container, pipelines)

    ' from Nancy docs at https://github.com/NancyFx/Nancy/wiki/The-Application-Before,-After-and-OnError-pipelines:
    '   The After pipeline is defined using the same syntax as the Before pipeline, and the passed in parameter is
    '   also the current NancyContext. The difference is that the hook does not return a value...
    '   ...The After hooks does not have any return value because one has already been produced by the appropriate
    '   route. Instead you get the option to modify (Or completely replace) the existing response by accessing the
    '   Response property of the NancyContext that Is passed in.
    pipelines.AfterRequest.AddItemToEndOfPipeline(AddressOf CheckHtmlMinify)
  End Sub

  ''' <summary>
  ''' Check if the response content type is HTML, and if so, minify using WebMarkupMin.
  ''' </summary>
  Private Shared Sub CheckHtmlMinify(context As NancyContext)

    ' get the current response contents
    Dim contents = context.Response.Contents

    ' is the current response content type HTML?
    If context.Response.ContentType = "text/html" Then
      ' HTML minifier
      ' will use default config from web.config
      Dim htmlMinifier = New WebMarkupMin.Core.Minifiers.HtmlMinifier
      ' current HTML, initially empty
      Dim currentHtml As String = String.Empty

      ' read current response contents (HTML) from stream, get as string
      ' adapted from https://gist.github.com/chrisnicola/1147568,
      ' https://stackoverflow.com/questions/11718310/nancy-accessing-rewriting-response
      Using ms = New MemoryStream()
        contents.Invoke(ms)
        ' go to start of stream
        ms.Position = 0
        ' read stream to end
        Using reader = New StreamReader(ms)
          currentHtml = reader.ReadToEnd
        End Using
      End Using

      Try
        ' minify HTML string using WebMarkupMin
        ' see docs at https://webmarkupmin.codeplex.com/wikipage?title=WebMarkupMin%201.X#HtmlMinifier_Chapter
        ' will return object containing minified string (and errors, statistics)
        ' uses settings from web.config file webMarkupMin/webExtensions
        Dim minifiedHtml = htmlMinifier.Minify(currentHtml)

        ' set response contents to minified HTML
        ' this will overwrite current contents
        context.Response.Contents =
          Function(strm)
            ' create a new stream from the minified HTML string
            Using writer = New MemoryStream(System.Text.Encoding.UTF8.GetBytes(minifiedHtml.MinifiedContent))
              ' write the stream to the response
              writer.CopyTo(strm)
            End Using
          End Function

      Catch ex As Exception
        ' do something with error here
        ' left out for brevity
      End Try
    End If

  End Sub

End Class
{% endhighlight %}

By dropping in my "NancyBootstrapperEx" class, any Nancy content returned as HTML will be minified and the code to return views from Nancy doesn't need to be altered:

```vb
Return View("viewname", viewdata)
```

The code could probably be extended to compress HTML too. After experimenting with different browsers (*cough* IE11 *cough*) I made one further change, using Nancy's fluent interface to add response headers telling the browser not to cache the returned view, like so:

```vb
Return View("viewname", viewdata).WithHeader("cache-control", "no-cache,no-store,must-revalidate").WithHeader("expires", "0")
```
