---
layout: post
title:  "Tales from the trenches, part 1"
date:   2020-07-31 12:00:00 +1000
categories: general
---
I've worked in IT for over 20 years, with great people, solving many unique problems alongside vendors, techies, and end-users.

Over that time I've collected a few "interesting" tales. I'm keeping the details vague to protect the innocent (and it could be I've mis-remembered some details too).

## The product "can" do this
I was part of a team that successfully worked with a vendor for several years. Early on in the relationship, while we were implementing their product, we'd ask "Can the product do _x_?", and the vendor would enthusiastically respond "Yes!"

We discovered the vendor interpreted the word "can" as "can be made to, with development effort"...not quite what we had in mind when we asked, usually to meet a specific need at the time.

**What we learnt:** the team changed the question to the more explicit "Can the product **in its current form** do _x_?", which helped manage expectations on our side and theirs.

## Time is valuable
We worked with a vendor who preferred to communicate via weekly teleconferences. At first, our small team would cram into an office around a phone to participate. But as months passed, progress stalled and the meetings became a rerun of outstanding items still "todo", copy-pasted from last week's agenda.

Eventually, we put in place a couple of measures - expecting e-mail responses from the vendor to open issues (instead of waiting to verbally deliver updates in the weekly meetings), and only requiring attendance if there was a reason for that team member to be there.

**My take-away:** Time is valuable. Meetings are unavoidable and potentially important but are sometimes run poorly; no agenda, could be better served by an e-mail or phone call, wrong people there, right people missing etc. I learnt from that experience 3 simple rules for meetings: start on time, come prepared, no distractions during the meeting.

## Embedded errors
While at uni I worked for a consulting company developing a Visual Basic app for a customer, that the customer distributed to end-users. This was "back in the day" when builds were finished, burnt to CD, and couriered to the customer (the internet then, wasn't what it is now!)

I got assigned a feature that needed error checking. I included code to generate an error, tested that the error was handled correctly, and started the build. Later that day, the customer rang to complain they were always getting an error when using the feature.

Red-faced, I explained that I'd left the error generation in the code. I removed it, and another CD was sent out.

**What I learnt that day:** Using `DEBUG` conditional attributes or flags will limit development code, to development environments. Even better, feature flags mean I can deploy code and turn on & off features at a later time.

## Edge cases
On that same Visual Basic app, I was asked to look over Bort's (*not his real name) feature to manage items in a list box.

It's funny now, but list boxes were pretty cool back then and looked professional. Bort had a list box that could hold up to 5 items, and "add", "delete" and "move item up/down" buttons. Basic functionality had been implemented but over the next couple of hours, we worked through use cases to end up with a more reliable feature, by addressing things like:

- what happens when "delete" is clicked with no item selected? Fix: enable delete only when an item is selected
- what happens when "add" is clicked when the list is full? Fix: disable add if there are already 5 items in the list
- what about clicking "move up" when an item is the first item in the list? Fix: disable "move up" when selecting the first item in the list
- what is selected after an item is deleted? What about after the only item in the list is deleted?
- _(and so on)..._

**A lesson that has stood the test of time:** Even though it's possible no-one would complain if Bort's list box was clunky and allowed illogical deletion and item moving, thinking through real-world use cases will reduce user frustration, and is worth putting time into.
