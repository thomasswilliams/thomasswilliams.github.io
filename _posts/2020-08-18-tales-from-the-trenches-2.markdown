---
layout: post
title:  "Tales from the trenches, part 2"
date:   2020-08-18 17:00:00 +1000
categories: general
---
Continuing from [part 1 here]({% post_url 2020-07-31-tales-from-the-trenches-1 %}), a couple more anonymised and sanitised stories from my years in IT.

## The shift key is not the enter key
Before uni, I worked at a hardware store. My exposure to IT was pretty limited there, but we did have a computer running software from a paint company that aimed to show customers what paint colors would look like, using pre-canned images of houses.

One day I found the house images in a directory on the computer. For fun, I opened up one of the images in Paint, drew some splotchy marks on it, and showed it to a co-worker. We laughed, I hit close, tabbed to the "No" button on the "Do you wish to save" prompt, and hit the enter key.

Nothing happened. The prompt stayed on the screen. Quickly, my co-worker grabbed the mouse and clicked "Yes", which saved the edited picture and left me to deal with the mess. Turned out I had hit the shift key on the prompt and not the enter key.

**Did I learn anything:** The shift key is not the enter key? Don't muck around with something unless you can restore it to where it was before you started?

## Really, really unique keys
One of the first big systems I designed, built and maintained myself was expected to hold a lot of financial data, for a long period of time. Back then, I was relatively new to SQL Server but had bumped into the issue of data type limits - for example, INTs could "only" hold numbers up to 2 billion. I thought I was very clever when I assigned the primary key of every table in my system to a universally unique identifier (UUID), which is a 36-character long sequence of letters and numbers that [Wikipedia][1] notes "While the probability that a UUID will be duplicated is not zero, it is close enough to zero to be negligible".

In other words, I would never, ever run out of UUIDs, and never have a duplicate.

The decision to use a UUID came back to bite me, as it required more space than a smaller data type, had no relation to the data (like an invoice number or other naturally-occurring number would have) and wasn't usable for ordering (if I'd used a different data type like an INT, the order would be preserved as newer records would have a larger INT than older records).

I also used a FLOAT data type for dollars, though I later changed this to a DECIMAL which was much better suited.

**Since then:** I've never again used a UUID for a primary key. BIGINT has been the most I've needed (which can hold numbers up to several million trillion). Choosing a UUID was a case of me "over-engineering" the solution.

## The best job in the world?
While at uni I worked lots of jobs around study - sorting and delivering mail in the mailroom, setting up exam halls, conducting end-of-semester feedback questionnaires, and more.

Seemingly the best job on campus was working the IT labs help desk at night. Why? The workload was small - hand students their printouts from a central photocopier, and answer the odd question - and the pay was good; the hours suited (weeknights from 5 to 9ish) and I could potentially do homework while manning the desk.

However, for me, the novelty soon wore off. I surfed the net and sporadically did homework (interruptions were a killer). I wasn't into network games like pretty much every other student in the labs and the help desk computer wasn't great; I had a better PC at home. I got very bored and eventually brought in novels to read (which was OK with the boss, they just needed somebody physically present).

**Learnings:** I was, and still am, grateful for the opportunities I had while at uni. The help desk didn't suit me and after a couple of months, I left.

[1]: https://en.wikipedia.org/wiki/Universally_unique_identifier
