---
title: "The Perks of Being a Mac (or FreeBSD) user"
summary: Your computer may know something you don't expected.
date: 2020-06-28T12:28:38+08:00
lastmod: 2020-06-28T22:30:38+08:00
draft: false
categories: ["Leisure"]
tags: ["mac", "easter-egg"]
thumbnail: https://images.unsplash.com/photo-1511075675422-c8e008f749d7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1000&q=80
---

> 🚨 Note: This is not a technical reading. If you want to have some fun and practice your `ls` and `cat` skills, this article may suit you.

## Table of Contents

- [Misc. files of the OS](#misc-file)
  - [The meaning of flowers](#meaning-of-flowers)
  - [The birthday present guide](#the-bday-guide)
- [Mac is a secret fan of...](#mac-is-a-secret-fan-of)
- [Bonus: the missing recipe](#bonus-recipe)

---

## Misc. Files of the OS {#misc-file}

I found some interesting files under `/usr/share/misc` of my MacBook:

```bash
-r--r--r--  1 root  wheel   3.1K Dec 14  2019 ascii
-r--r--r--  1 root  wheel   374B Dec 14  2019 birthtoken
-r--r--r--  1 root  wheel   2.9K Dec 14  2019 eqnchar
-r--r--r--  1 root  wheel   1.4K Dec 14  2019 flowers
-r--r--r--  1 root  wheel   508B Dec 14  2019 getopt
-rw-r--r--  1 root  wheel   941B Dec 14  2019 mail.help
-rw-r--r--  1 root  wheel   1.3K Dec 14  2019 mail.tildehelp
-r--r--r--  1 root  wheel   310B Dec 14  2019 man.template
-r--r--r--  1 root  wheel   948B Dec 14  2019 mdoc.template
-r--r--r--  1 root  wheel   425B Dec 14  2019 operator
-r--r--r--  1 root  wheel    78K May 27 11:38 trace.codes
-rw-r--r--  1 root  wheel    13K Dec 14  2019 units.lib
```

## The Meaning of Flowers {#meaning-of-flowers}

`/usr/share/misc/flowers` lists out the meaning of flowers[^1]. Check this out if you are going to buy some flowers but you don't know what you should buy. 

```
# Flower : Meaning
#	@(#)flowers	8.1 (Berkeley) 6/8/93
#
# Upside down reverses the meaning.
African violet:Such worth is rare.
Apple blossom:Preference.
Bachelor's button:Celibacy.
Bay leaf:I change but in death.
Camelia:Reflected loveliness.
Chrysanthemum, other color:Slighted love.
Chrysanthemum, red:I love.
Chrysanthemum, white:Truth.
Clover:Be mine.
Crocus:Abuse not.
Daffodil:Innocence.
Forget-me-not:True love.
Fuchsia:Fast.
Gardenia:Secret, untold love.
Honeysuckle:Bonds of love.
Ivy:Friendship, fidelity, marriage.
Jasmine:Amiability, transports of joy, sensuality.
Leaves (dead):Melancholy.
Lilac:Youthful innocence.
Lilly of the valley:Return of happiness.
Lilly:Purity, sweetness.
Magnolia:Dignity, perseverance.
Marigold:Jealousy.
Mint:Virtue.
Orange blossom:Your purity equals your loveliness.
Orchid:Beauty, magnificence.
Pansy:Thoughts.
Peach blossom:I am your captive.
Petunia:Your presence soothes me.
Poppy:Sleep.
Rose, any color:Love.
Rose, deep red:Bashful shame.
Rose, single, pink:Simplicity.
Rose, thornless, any color:Early attachment.
Rose, white:I am worthy of you.
Rose, yellow:Decrease of love, rise of jealousy.
Rosebud, white:Girlhood, and a heart ignorant of love.
Rosemary:Remembrance.
Sunflower:Haughtiness.
Tulip, red:Declaration of love.
Tulip, yellow:Hopeless love.
Violet, blue:Faithfulness.
Violet, white:Modesty.
Zinnia:Thoughts of absent friends.
```

## The Birthday Present Guide {#the-bday-guide}

Check out the `/usr/share/misc/birthtoken`[^2] and see which gem and flower (looks like someone in Berkeley knows about the flowers really well) you should buy for your friends!

> *"Oh why you choose this gem and that flower as the present?"*
>
> *"Um... that's my computer's idea..."*

### More About Perl and Ruby

The creator of [Ruby](https://www.ruby-lang.org) chose the name *Ruby* because it was [the birthstone of one of his colleagues](https://ruby-doc.org/docs/ruby-doc-bundle/FAQ/FAQ.html) and that is the gem right after Pearl ([Perl](https://www.perl.org/)).

**Lesson learnt:** when you try to name a new language you invented, you should check this file out!

```
# Birthday : Birth Stone : Birth Flower
#	@(#)birthtoken	8.1 (Berkeley) 6/8/93
January:Garnet:Carnation
February:Amethyst:Violet
March:Aquamarine:Jonquil
April:Diamond:Sweetpea
May:Emerald:Lily Of The Valley
June:Pearl:Rose
July:Ruby:Larkspur
August:Peridot:Gladiolus
September:Sapphire:Aster
October:Opal:Calendula
November:Topaz:Chrysanthemum
December:Turquoise:Narcissus
```

## Mac is a Secret Fan of... {#mac-is-a-secret-fan-of}

The `/usr/share/calendar` folder contains some useful calendars but this one really catches my eye:

```bash
-rw-r--r--  1 root  wheel   1.4K Dec 14  2019 calendar.lotr
```

This is a timeline of the important events happened in *The Lord Of The Rings*[^3]:

```
/*
 * Lord Of The Rings
 *
 * $FreeBSD: src/usr.bin/calendar/calendars/calendar.lotr,v 1.2 2003/10/09 00:31:48 grog Exp $
 */

#ifndef _calendar_lotr_
#define _calendar_lotr_

01/05	Fellowship enters Moria
01/09	Fellowship reaches Lorien
01/17	Passing of Gandalf
02/07	Fellowship leaves Lorien
02/17	Death of Boromir
02/20	Meriadoc & Pippin meet Treebeard
02/22	Passing of King Elessar
02/24	Ents destroy Isengard
02/26	Aragorn takes the Paths of the Dead
03/05	Frodo & Samwise encounter Shelob
03/08	Deaths of Denethor & Theoden
03/18	Destruction of the Ring
03/29	Flowering of the Mallorn
04/04	Gandalf visits Bilbo
04/17	An unexpected party
04/23	Crowning of King Elessar
05/19	Arwen leaves Lorien to wed King Elessar
06/11	Sauron attacks Osgiliath
06/13	Bilbo returns to Bag End
06/23	Wedding of Elessar & Arwen
07/04	Gandalf imprisoned by Saruman
07/24	The ring comes to Bilbo
07/26	Bilbo rescued from Wargs by Eagles
08/03	Funeral of King Theoden
08/29	Saruman enters the Shire
09/10	Gandalf escapes from Orthanc
09/14	Frodo & Bilbo's birthday
09/15	Black riders enter the Shire
09/18	Frodo and company rescued by Bombadil
09/28	Frodo wounded at Weathertop
10/05	Frodo crosses bridge of Mitheithel
10/16	Boromir reaches Rivendell
10/17	Council of Elrond
10/25	End of War of the Ring
11/16	Bilbo reaches the Lonely Mountain
12/05	Death of Smaug
12/16	Fellowship begins Quest

#endif /* !_calendar_lotr_ */
```

## Bonus: the missing recipe {#bonus-recipe}

In the eariler versions of the macOS, **a hidden cookie recipe** can be found by typing this command in the Terminal:

```bash
Open /usr/share/emacs/22.1/etc/COOKIES
```

Unforrunately in the latest macOS this file is gone (together with `/usr/share/emacs`). We can only check this out [on the Apple Open Source website](https://opensource.apple.com/source/emacs/emacs-96/emacs/etc/COOKIES.auto.html)[^4].

[^1]: https://github.com/lattera/freebsd/blob/master/share/misc/flowers
[^2]: https://github.com/lattera/freebsd/blob/master/share/misc/birthtoken
[^3]: https://opensource.apple.com/source/misc_cmds/misc_cmds-31/calendar/calendars/calendar.lotr.auto.html
[^4]: https://opensource.apple.com/source/emacs/emacs-96/emacs/etc/COOKIES.auto.html

