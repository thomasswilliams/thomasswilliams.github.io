---
layout: post
title:  "Happy Christmas!"
date:   2025-12-02 12:00:00 +1100
categories: general
---

A different post for Christmas...

Although my experience of Christmas in Australia is that it's middle-of-summer hot, I thought it could be "cool" to do a snow Christmas themed post, demonstrating some CSS tricks I adapted from a post I read years ago at <https://codeconvey.com/pure-css-falling-snowflake-animation>.

If you're reading this in a feed reader, you won't be able to see the Christmas theme & CSS animations - which, by the way, are very lightweight and don't use any images.

The code I adapted is simple and you can add to your own web pages: first, an outer DIV with many empty italic/emphasis tags placed anywhere on the page, under the `body` tag:

```html
<div class="snowflakes">
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i>
</div>
```

Next is the CSS where all the magic happens - again, without using images - by converting those italic tags to asterisks. I've tweaked the original a little and added some comments, feel free to play around with the animation timings and other properties.

You'll notice the snow falling animation only runs for the first screen height of a long page. When you scroll down, the effect is off-screen (I'm OK with this):

```css
/* make the "snowflakes" outer DIV cover the entire screen */
.snowflakes {
  width: 100%;
  /* make taller than the screen so snowflakes go past bottom */
  height: 1700px;
  position: absolute;
  /* start above the top of the screen so the snowflakes don't "pop" in */
  top: -90px;
  left: 0;
  overflow: hidden;
  /* display underneath other DIVs */
  z-index: -1;
  /* can't select anything in the DIV */
  user-select: none;
}
/* color of individual snowflake italic tags, some variation
   colors should work on dark and light backgrounds */
.snowflakes i,
.snowflakes i:after,
.snowflakes i:before {
  background: #8C96EC;
}
.snowflakes i:nth-child(11n),
.snowflakes i:nth-child(11n):after,
.snowflakes i:nth-child(11n):before {
  background: #aea1c6;
}
.snowflakes i:nth-child(19n),
.snowflakes i:nth-child(19n):after,
.snowflakes i:nth-child(19n):before {
  background: #7aa3be;
}
/* apply the "snowflakes" animation to the italic tags */
.snowflakes i {
  display: inline-block;
  /* note the duration & timing for some of the flakes is overwritten below */
  animation: snowflakes 3s linear 2s 20;
  position: relative;
}
/* "before" and "after" pseudo-elements */
.snowflakes i:after,
.snowflakes i:before {
  /* make before and after pseudo-elements same size as element */
  height: 100%;
  width: 100%;
  /* give it some content so is visible and takes space */
  content: ".";
  position: absolute;
  top: 0px;
  left: 0px;
  /* rotate by 120 degrees (note "before" is overridden below) */
  transform: rotate(120deg);
}
/* rotate "before" by 240 degrees, so now we have an asterisk */
.snowflakes i:before {
  transform: rotate(240deg);
}
/* define animation: starts at top of page, ends at bottom following a wavy
   pattern; rotated 360 degrees; fades out at end */
@keyframes snowflakes {
  0% {
    transform: translate3d(0, 0, 0) rotate(0deg) scale(0.6);
    opacity: 1;
  }
  100% {
    transform: translate3d(15px, 1200px, 0) rotate(360deg) scale(0.6);
    opacity: 0;
  }
}
/* different size snowflakes, falling at different rates
   introduce some (almost) randomness using prime number spacing
   based on "Cicada principle"
   e.g. https://www.the215guys.com/learning/nth-child-cicada-principle/ */
.snowflakes i:nth-child(2n) {
  width: 16px;
  height: 4px;
  animation-duration: 5.1s;
  animation-iteration-count: 37;
  transform-origin: right -41px;
}
.snowflakes i:nth-child(3n) {
  width: 18px;
  height: 5px;
  animation-duration: 6.7s;
  animation-iteration-count: 11;
  transform-origin: right -29px;
}
.snowflakes i:nth-child(5n) {
  width: 24px;
  height: 6px;
  animation-duration: 8.3s;
  animation-iteration-count: 17;
  transform-origin: right -11px;
}
.snowflakes i:nth-child(11n) {
  width: 28px;
  height: 7px;
  animation-duration: 11.1s;
  animation-iteration-count: 13;
  transform-origin: right -19px;
}
.snowflakes i:nth-child(13n) {
  width: 32px;
  height: 8px;
  animation-duration: 13.7s;
  animation-iteration-count: 7;
  transform-origin: right -3px;
}
/* different delays so they don't all start at the same time, different opacity to make
   some look like they're behind others */
.snowflakes i:nth-child(2n+1) {
  opacity: 0.3;
  animation-delay: 0s;
  animation-timing-function: ease-in;
}
.snowflakes i:nth-child(3n+2) {
  opacity: 0.4;
  animation-delay: 0.7s;
  animation-timing-function: ease-out;
}
.snowflakes i:nth-child(5n+3) {
  opacity: 0.5;
  animation-delay: 1.3s;
  animation-timing-function: linear;
}
.snowflakes i:nth-child(7n+1) {
  opacity: 0.6;
  animation-delay: 2.1s;
  animation-timing-function: ease-in-out;
}
.snowflakes i:nth-child(11n+1) {
  opacity: 0.7;
  animation-delay: 2.7s;
  animation-timing-function: ease;
}
.snowflakes i:nth-child(13n+1) {
  opacity: 0.8;
  animation-delay: 3.1s;
}
.snowflakes i:nth-child(17n+1) {
  opacity: 0.9;
  animation-delay: 3.7s;
}
```

Happy Christmas!

<!-- code for snowflakes effect in page, adapted from https://codeconvey.com/pure-css-falling-snowflake-animation/ -->
<div class="snowflakes">
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i>
</div>

<style>
  /* make the "snowflakes" outer DIV cover the entire screen */
  .snowflakes {
    width: 100%;
    /* make taller than the screen so snowflakes go past bottom */
    height: 1700px;
    position: absolute;
    /* start above the top of the screen so the snowflakes don't "pop" in */
    top: -90px;
    left: 0;
    overflow: hidden;
    /* display underneath other DIVs */
    z-index: -1;
    /* can't select anything in the DIV */
    user-select: none;
  }
  /* color of individual snowflake italic tags, some variation
     colors should work on dark and light backgrounds */
  .snowflakes i,
  .snowflakes i:after,
  .snowflakes i:before {
    background: #8C96EC;
  }
  .snowflakes i:nth-child(11n),
  .snowflakes i:nth-child(11n):after,
  .snowflakes i:nth-child(11n):before {
    background: #aea1c6;
  }
  .snowflakes i:nth-child(19n),
  .snowflakes i:nth-child(19n):after,
  .snowflakes i:nth-child(19n):before {
    background: #7aa3be;
  }
  /* apply the "snowflakes" animation to the italic tags */
  .snowflakes i {
    display: inline-block;
    /* note the duration & timing for some of the flakes is overwritten below */
    animation: snowflakes 3s linear 2s 20;
    position: relative;
  }
  /* "before" and "after" pseudo-elements */
  .snowflakes i:after,
  .snowflakes i:before {
    /* make before and after pseudo-elements same size as element */
    height: 100%;
    width: 100%;
    /* give it some content so is visible and takes space */
    content: ".";
    position: absolute;
    top: 0px;
    left: 0px;
    /* rotate by 120 degrees (note "before" is overridden below) */
    transform: rotate(120deg);
  }
  /* rotate "before" by 240 degrees, so now we have an asterisk */
  .snowflakes i:before {
    transform: rotate(240deg);
  }
  /* define animation: starts at top of page, ends at bottom following a wavy
    pattern; rotated 360 degrees; fades out at end */
  @keyframes snowflakes {
    0% {
      transform: translate3d(0, 0, 0) rotate(0deg) scale(0.6);
      opacity: 1;
    }
    100% {
      transform: translate3d(15px, 1200px, 0) rotate(360deg) scale(0.6);
      opacity: 0;
    }
  }
  /* different size snowflakes, falling at different rates
     introduce some (almost) randomness using prime number spacing
     based on "Cicada principle"
     e.g. https://www.the215guys.com/learning/nth-child-cicada-principle/ */
  .snowflakes i:nth-child(2n) {
    width: 16px;
    height: 4px;
    animation-duration: 5.1s;
    animation-iteration-count: 37;
    transform-origin: right -41px;
  }
  .snowflakes i:nth-child(3n) {
    width: 18px;
    height: 5px;
    animation-duration: 6.7s;
    animation-iteration-count: 11;
    transform-origin: right -29px;
  }
  .snowflakes i:nth-child(5n) {
    width: 24px;
    height: 6px;
    animation-duration: 8.3s;
    animation-iteration-count: 17;
    transform-origin: right -11px;
  }
  .snowflakes i:nth-child(11n) {
    width: 28px;
    height: 7px;
    animation-duration: 11.1s;
    animation-iteration-count: 13;
    transform-origin: right -19px;
  }
  .snowflakes i:nth-child(13n) {
    width: 32px;
    height: 8px;
    animation-duration: 13.7s;
    animation-iteration-count: 7;
    transform-origin: right -3px;
  }
  /* different delays so they don't all start at the same time, different opacity to make
    some look like they're behind others */
  .snowflakes i:nth-child(2n+1) {
    opacity: 0.3;
    animation-delay: 0s;
    animation-timing-function: ease-in;
  }
  .snowflakes i:nth-child(3n+2) {
    opacity: 0.4;
    animation-delay: 0.7s;
    animation-timing-function: ease-out;
  }
  .snowflakes i:nth-child(5n+3) {
    opacity: 0.5;
    animation-delay: 1.3s;
    animation-timing-function: linear;
  }
  .snowflakes i:nth-child(7n+1) {
    opacity: 0.6;
    animation-delay: 2.1s;
    animation-timing-function: ease-in-out;
  }
  .snowflakes i:nth-child(11n+1) {
    opacity: 0.7;
    animation-delay: 2.7s;
    animation-timing-function: ease;
  }
  .snowflakes i:nth-child(13n+1) {
    opacity: 0.8;
    animation-delay: 3.1s;
  }
  .snowflakes i:nth-child(17n+1) {
    opacity: 0.9;
    animation-delay: 3.7s;
  }
</style>
