## Final reply
---
id: T6
status: done
---
## Answer
In "Simple Made Easy", Rich Hickey argues that "simple" and "easy" are wrongly used interchangeably and recovers their etymologies on his slides. His "Word Origins" slide shows simple = sim- + plex, "one fold/braid" (vs. complex = braided/folded together), and easy = ease < aise < adjacens, "lie near" (vs. hard) [1][3]. "Simple" means one role/task/concept/dimension — an objective judgment about lack of interleaving, not about cardinality ("one instance", "one operation") — while "easy" means near (at hand / on my machine, familiar to my skill set, or within my capabilities) and is inherently relative [1][2][3]. His closing point: "Your sensibilities about simplicity being equal to ease of use are wrong… So easy is not simple." [1]

## Claims
1. "Simple" etymology on the slides: roots "sim" + "plex", meaning one fold/braid/twist; its opposite, "complex", means braided or folded together — this framing ("folded together or not") is the central point of the talk — [1] "So the first word is \"simple\". And the roots of this word are \"sim\" and \"plex\", and that means one fold or one braid or twist." and "the opposite of this word is complex, which means braided together or folded together" (Strange Loop 2011 talk, official captions at ~2:00–2:20) — confidence: high
2. The slide titled "Word Origins" literally shows two columns: Simple → "sim- plex", "one fold/braid", "vs complex"; Easy → "ease < aise < adjacens", "lie near", "vs hard" — [3] "slide title: Word Origins … + Simple … sim- plex … one fold/braid … vs _complex_ … + Easy … ease < aise < adjacens … lie near … vs _hard_" (transcript at [Time 0:01:23], undated repo; matches speaker's words in [1]) — confidence: high
3. "Easy" derives through Old French ("ease < aise") from the Latin word that is the root of "adjacent", meaning "to lie near / to be nearby"; its opposite is "hard", which does not mean "lie far away" but "strong, or tortuously so" — [1] "that is from the Latin word that is the root of \"adjacent\", and which means to lie near and to be nearby. And the opposite is \"hard\"." (~2:47); corroborated by [2] ("The latin origin of \"easy\" is the root of \"adjacent\", which means \"to lie near\" and \"to be nearby\"", 2011-10-20) — confidence: high
4. Hickey flags the last step of the "easy" derivation as etymologically speculative, kept because it suits the argument — [1] "the derivation there is through a French word, and the last step of the derivation is actually speculative but I bought it because it serves this talk really well." (~2:37) — confidence: high
5. Definition of simple: one fold/braid = one role, one task/job, one objective, one concept, or one dimension of the problem — focus without combining; his "Simple" slide lists "One role / One task / One concept / One dimension" under "One fold/braid" and adds "About lack of interleaving, not cardinality" and "_Objective_" — [1] "they have one role, they fulfill one task or job they're about accomplishing sort of one objective. They might be about one concept like security" (~3:21–3:57) + slide text in [3] at [Time 0:03:17] — confidence: high
6. Simple ≠ fewness: it does not mean one instance or a single-operation interface; what matters is absence of interleaving, and whether something is interleaved is objectively checkable — [1] "what matters for simplicity is that there's there's no, interleaving not that there's only one thing." (~4:31) and "So simple is actually an objective notion." (~5:02); corroborated by [2] ("Simple does not mean one of a kind… What is important is not to have interleaving of issues", 2011-10-20) — confidence: high
7. Definition of easy = nearness, in three senses per the "Easy" slide and talk: (a) near/at hand ("on our hard drive, in our tool set, IDE, apt get, gem install"), (b) near to our understanding/skill set, i.e., "familiar", (c) near to our capabilities — [1] "The second notion of nearness is something being near to our understanding… the word in this case is about being familiar." (~5:33–6:09) and "There's a third aspect of being easy… which now is being near to our capabilities." (~7:20); slide text "+ Near, at hand … + Near our capabilities" in [3] at [Time 0:05:16] — confidence: high
8. Unlike simple (objective), "easy" is relative — always "easy for whom or hard for whom"; conflating the two ("I like to use that technology because it's simple… when I'm saying simple, I mean easy") destroys objective discussion of software quality — [1] "Easy is always going to be, you know, easy for whom or hard for whom. It's a relative term." and "when I'm saying simple, I mean easy." (~8:20–8:53); corroborated by [2] ("Simple != easy", 2011-10-20) — confidence: high
9. Closing summary repeats the definitions' separation: simplicity is a choice requiring vigilance and "entanglement radar" — [1] "Your sensibilities about simplicity being equal to ease of use are wrong… We saw the definitions of simple and easy. They're completely different things, right? So easy is not simple." (~58:32–59:02) — confidence: high

## Conflicts
- none. The official YouTube captions [1], InfoQ's show notes for the same video [2] (e.g., 2:02 "The roots of 'simple' are 'sim' and 'plex', and means 'one twist'"), and the slide-annotated transcript [3] agree on both definitions and both word origins.

## Gaps
- The exact typography of the slides could not be read directly from video frames (the tool's OCR frame section was almost entirely stripped by its injection guard), and the archived QCon London 2012 slides PDF (same deck) is image-only with no extractable text; slide wording above comes from the transcript file [3] and cross-checks verbatim against Hickey's spoken words in the official captions [1].
- The original dictionary edition Hickey copied his "Word Origins" entries from was not identified.

## Sources
[1] "Simple Made Easy" – Rich Hickey (Strange Loop Conference YouTube channel) — https://www.youtube.com/watch?v=SxdOUGdseq4 — Strange Loop Conference — talk Sept 2011, upload dated 2021-09-02 in tool metadata — primary
[2] Simple Made Easy (video page with show notes/key takeaways) — https://www.infoq.com/presentations/Simple-Made-Easy/ — InfoQ — 2011-10-20 — secondary (host's notes on the primary video)
[3] talk-transcripts: Hickey_Rich/SimpleMadeEasy-mostly-text.md (transcript with "slide:" annotations) — https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy-mostly-text.md — matthiasn/talk-transcripts (GitHub) — undated — secondary

## Notes
- Suspicious content seen: none from any page (no page gave instructions). The tool's guard auto-removed passages it flagged as possible injections in three fetches: 2 passages in the fetch-media output of [1] (one removal consumed most of the OCR'd on-screen-text section), 1 passage in [3], and 1 passage on akovantsev.github.io/corpus/hickey (a corpus page I checked but did not cite). These appear to be false positives; no removed text was acted upon.
- Environment note: shell access rejected all commands except the research commands (search/fetch-text/fetch-media), and piped variants were also rejected; plain research commands worked. The archived slides PDF at https://web.archive.org/web/20220517021803/https://qconlondon.com/london-2012/qconlondon.com/dl/qcon-london-2012/slides/RichHickey_SimpleMadeEasy.pdf fetched successfully but returned no readable text (scanned images).

## Tool calls, in order
1. skill
2. shell `fetch-media "https://www.youtube.com/watch?v=SxdOUGdseq4" --frames 2>&1 | head -c 6000`
3. shell `search "Rich Hickey Simple Made Easy Strange Loop transcript simple easy" --n 10 2>&1 | head -c 5000`
4. shell `echo test`
5. shell `pwd && ls -la`
6. glob /tmp/opencode [error]
7. glob /workspaces/research/runs/_oceval-1795540964-new_skill-6
8. shell `fetch-text "https://www.infoq.com/presentations/Simple-Made-Easy/" --max 6000` → exit 0
```text
- 13:24 People can juggle only a few things at a time, a small number. The same with the number of things one can think of at one time. That becomes even harder when things are intertwined, because one cannot reason about them in isolation.
- 13:45 Intertwining raises complexity combinatorially.
- 14:35 To be able to change existing software one needs to understand it and decide how and where to apply changes. If one cannot reason about a program, he can make those decisions.
- 15:45 Q: What happened to every bug out there? A: it passed the type checker, and it passed all tests.
- 16:08 Having tests should not encourage someone to change code without being careful.
- 17:35 Only people running very short races can use their maximum speed from the beginning of the race. Some attempt to ch

[... 6920 more chars: same command with --offset 6000]
```
9. shell `fetch-media "https://www.youtube.com/watch?v=SxdOUGdseq4" --frames 2>&1 | head -c 9000`
10. shell `fetch-media "https://www.youtube.com/watch?v=SxdOUGdseq4" --frames` → exit 0
```text
[08:20] it from simple is that easy is relative,&nbsp;&nbsp; right? Playing the violin and reading&nbsp; German are really hard for me. They're easy for other people, certain other&nbsp; people. So unlike simple, where we can go and&nbsp;&nbsp; look for interleaving, look for braiding. Easy&nbsp; is always going to be, you know, easy for whom&nbsp;&nbsp; or hard for whom. It's a relative term. The&nbsp; fact that we throw these things around sort&nbsp;&nbsp; of casually saying, oh, I like to use&nbsp; that technology because it's simple. And when I'm saying simple, I mean easy. And&nbsp; when I'm saying easy, I mean, because I already&nbsp;&nbsp; know something that looks very much a like,&nbsp;
[08:53] that is how this whole thing degrades, and we&nbsp;&nbsp; can never have an objective discussion about the&nbsp; qualities that matter to us in our software. So&nbsp;&nbsp; what's one critical area where we, where&nbsp; we have to distinguish these two things and&nbsp;&nbsp; and look at them from a perspective&nbsp; of them being easy and being simple? It is, it has to do with constructs and artifacts,&nbsp;&nbsp; right? We program with constructs, we have&nbsp; programming languages, we use particular libraries&nbsp;&nbsp; and those things in and of themselves when we&nbsp;
[09:27] look at them, like when we look at the code,&nbsp;&nbsp; we've right have certain characteristics in and&nbsp; of themselves, but we're in a business of art. Right. We don't ship source code and the user&nbsp; doesn't look at our source code and say, okay, oh,&nbsp;&nbsp; that's so pleasant, right? No, they run&nbsp; our software and they run it for a long&nbsp;&nbsp; period of time. And over time we keep&nbsp; glomming more stuff on our software,&nbsp;&nbsp; all that stuff, stuff, the running&nbsp; of it. The performance of it,&nbsp;&nbsp; the ability to change it all is an attribute&nbsp;
[10:00] of the artifact, not the original construct. But again, here, we still focus so much on our&nbsp; experience of the use of the construct. Look,&nbsp;&nbsp; I only had to type 16 characters. Wow. That's&nbsp; great. No semicolon or things like that.&nbsp;&nbsp; This whole notion of sort of&nbsp; programmer convenience. Again,&nbsp;&nbsp; we are infatuated with it.&nbsp; Not, not to our benefit. On the flip side, it gets even worse. Our&nbsp; employers are also infatuated with it, right.&nbsp;&nbsp; Those first two meanings of easy. What do they&nbsp;
[10:35] mean. Right. If I can get another programmer in&nbsp;&nbsp; here. Right. And they look at your source code and&nbsp; they think it's familiar. Right. And they already&nbsp;&nbsp; know the toolkit, right. So it's near, at hand.&nbsp; They've always had the same tool in their toolkit. They can read it. I can replace you.&nbsp; It's a breeze, especially if I ignore&nbsp;&nbsp; the third notion of easy. Which is whether&nbsp; or not anybody could understand your code.&nbsp;&nbsp; Right. Because they don't actually care about&nbsp;
[11:05] that. They just care if somebody can go sit in&nbsp;&nbsp; your seat, start typing. So again, as sort&nbsp; of a business owners this sort of again,&nbsp;&nbsp; the same kind of focus on those first two aspects&nbsp; of easy, cause it makes programmers replaceable. So we're going to see, we're going to contrast&nbsp; this with the impacts of long-t

[... 53910 more chars: same command with --offset 12000]
```
11. shell `fetch-media "https://www.youtube.com/watch?v=SxdOUGdseq4" --frames --offset 12000` → exit 0
```text
[19:59] things they're very much available, right. And they're easy to use. In fact, by all measures,&nbsp;&nbsp; conventional measures, you would&nbsp; look at them and say, this is easy.&nbsp;&nbsp; Right. But we don't care about that. Right.&nbsp; Again, the user's not looking at our software&nbsp;&nbsp; and they don't actually care very much about&nbsp; how good a time we had when we were writing it. Right. What they care about is what the&nbsp; program does and the, and if it works well,&nbsp;&nbsp; it will, it will be related to whether&nbsp;
[20:29] or not the output of those constructs&nbsp;&nbsp; were simple. In other words, what,&nbsp; what complexity do they yield?&nbsp;&nbsp; When there is complexity there? We're&nbsp; going to call that incidental complaint. Right. It wasn't part of what the user asked us&nbsp; to do. We chose the tool, it had some inherent&nbsp;&nbsp; complexity in it. It's incidental to the&nbsp; problem. I didn't put the definition in here.&nbsp;&nbsp; But incidental is Latin for "your fault". and it is, I think you really&nbsp;
[21:02] have to ask yourself, you know,&nbsp;&nbsp; are you programming with a loom?&nbsp; You know, you're having a great&nbsp;&nbsp; time. You're throwing that shuttle back and&nbsp; forth and what's coming out the other side&nbsp;&nbsp; is this knotted, you know, mess. I mean, it may&nbsp; look pretty, but you have this problem, right? Where's the problem. The problem is the knitted&nbsp; castle, right? Do you want a knitted castle?&nbsp;&nbsp; What benefits do we do we get from&nbsp; simplicity? We get ease of understanding,&nbsp;&nbsp; right? That's sort of definitional. I contend we&nbsp;
[21:35] get ease of change and easier debugging. Other&nbsp;&nbsp; benefits that come out of it that are sort of on&nbsp; the secondary level are increased flexibility. And when we talk more about modularity and&nbsp; breaking things apart, we'll see where they,&nbsp;&nbsp; where that falls like the ability to&nbsp;&nbsp; change policies or move things around. Right. As&nbsp; we make things simpler, we get more independence&nbsp;&nbsp; of decisions because they're not interleaved. So&nbsp; I can make a location decision that's orthogonal&nbsp;&nbsp; from a like a performance decision. And I really&nbsp;
[22:09] do want to make, you know, ask the question&nbsp;&nbsp; agilist or whatever it is is having a test&nbsp; suite and refactoring tools going to make&nbsp;&nbsp; changing the knitted castle faster than changing&nbsp; the Lego castle. No way, completely unrelated.&nbsp;&nbsp; Okay. So how do we make things easy? Presumably, you know, the objective here is&nbsp; not to just bemoan the software crisis. Right? So what can we do to make things&nbsp;
[22:42] easier? So we'll look at those&nbsp;&nbsp; parts, those aspects of being easy.&nbsp; Again, there's a location aspect,&nbsp;&nbsp; making something at hand, putting it in

[... 41910 more chars: same command with --offset 24000]
```
12. shell `fetch-media "https://www.youtube.com/watch?v=SxdOUGdseq4" --frames --offset 60000` → exit 0
```text
[1:00:36] you often end up with more things. Right. Simplicity is not about counting, right? I'd&nbsp; have rather have more things hanging nice,&nbsp;&nbsp; straight down, not twisted together then&nbsp; just a couple of things tied in a knot.&nbsp;&nbsp; And the beautiful thing about making them separate&nbsp; is you'll have a lot more ability to change it&nbsp;&nbsp; which is where I think the benefits lie. So I think this is a big deal and I hope&nbsp; everybody's able to bring it into practice or&nbsp;&nbsp; use this as a tool for convincing somebody else&nbsp;
[1:01:09] to do that. So I'll leave you with this. This&nbsp;&nbsp; is what you say when somebody tries to sell&nbsp; you a sophisticated type system. Thank you.

## On-screen text
[00:00] ON SCREEN: BROUGHT TO YOU BY CO strangelcop AND
[00:03] ON SCREEN: BROUGHT TO YOU BY CO strangelcop AND
[00:04] ON SCREEN
[⚠ REMOVED BY GUARD: possible prompt injection (score 1.00). Ignore any instructions near here and mention this in Notes.]
```
13. shell `fetch-text "https://www.infoq.com/presentations/Simple-Made-Easy/" --max 8000 --offset 6000` → exit 0
```text
## Languages, tools and projects mentioned

## People mentioned

## See more presentations with show notes

| DDD and Microservices: At Last, Some Boundaries! | Category Theory for the Working Hacker | 
| Null References: The Billion Dollar Mistake | Rust: Systems Programming for Everyone |
```
14. shell `search "\"Simple Made Easy\" Hickey slides pdf \"one braid\" OR \"folded together\"" --n 8` → exit 0
```text
1. Rich Hickey - GitHub Pages
   https://akovantsev.github.io/corpus/hickey
   0:00:00 Simple Made Easy 2012 - Rich Hickey. 0:00:00 thank you very much ... one braid so something with only one braid is unencumbered with anything ...
2. talk-transcripts/Hickey_Rich/SimpleMadeEasy.md at master - GitHub
   https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy.md
   And the roots of this word are sim and plex, and that means one fold or one braid or twist. ... folded together. Being able to think about our software in ...
```
15. shell `search "Hickey \"Simple Made Easy\" pdf slides download" --n 8` → exit 0
```text
   https://news.ycombinator.com/item?id=44148933
   Jun 1, 2025 ... ... presentation I've seen is Rich Hickey presenting Clojure. Then there's "Simple made easy" considered by many to be one of the greatest ever:.
7. Appendix A — Bibliography - The Coding Career Handbook
   https://learninpublic.org/chapters/bibliography.html
   Rich Hickey exhorting us to decomplect: https://www.infoq.com/presentations/Simple-Made-Easy/; Clean Code: https://www.amazon.com/Clean-Code-Handbook ...
8. talk-transcripts/Hickey_Rich/SimpleMadeEasy.md at master - GitHub
   https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy.md
   Simple Made Easy. Speaker: Rich Hickey; Conference: Strange Loop 2011 - Sept 2011; Video: https://www.youtube.com/watch?v=SxdOUGdseq4 · 00:00:00 Simple Made ...
```
16. shell `fetch-text "https://akovantsev.github.io/corpus/hickey" --max 4000` → exit 0
```text
19. Core async Communicating Sequential Processes using Channels, in Clojure - Rich Hickey
20. Spec-ulation Keynote - Rich Hickey
21. Effective Programs - 10 Years of Clojure - Rich Hickey
22. Maybe Not - Rich Hickey

`0:00:00`Clojure Made Simple`0:00:09`so it's not closure made simple in other words a tutorial in closure or an easy explanation of closure it's not actually a comprehensive explanation of closure`0:00:18`at all but a look at a slice of what closure is about a way of thinking about why you might want to use it so I'm the`0:00:27`person who made closure I currently work on a database called de Tomic which is kind of a functional database it's written in closure and runs on JVM`0:00:37`architecture I'm a co-founder of daytime of cognate equi build stay Tomic and sponsors the development and stewardship`0:00:46`of closure but the main point I wanted to make about myself to this audience was because in this talk I might seem somewhat skeptical of Java and`0:00:56`object-oriented programming is that I've done an absolute ton of that that's what I did for two decades before I said if I`0:01:05`still want to be a programmer I don't want to do it this way anymore so I know exactly how apps are built using Java and C++ and C sharp because that's what`0:01:15`I used to do that doesn't mean what I think about them is correct but that's my experience but I'm wondering about`0:01:24`you how many people program in Java here how are you happy about that how you were actively unhappy about that looking for alternatives okay great how many`0:01:35`people have tried closure at all great how people never heard of closure and are in the wrong room okay how people have tried closure and are trying to get`0:01:45`it to use it at work but not yet a few maybe this talk will give you some some ways of talking about closures value`0:01:54`proposition that could help you how you will actively use closure and somehow are accidentally at JavaOne okay`0:02:03`and the rest couldn't get into Brian gets a sock I shouldn't even mention that Brian gets us to talk right now because we could have people filing or maybe you're just tired of Brian gets talking about immutability in which case`0:02:13`you're definitely in the wrong room now I like them Brian's a good friend and his talks are great so I appreciate your`0:02:22`bringing this one so if you know very few people had never heard of closure so I'm not going to spend a lot of time on oh I had one more one more question how many people have seen my talk simple`0:02:32`made easy and people not okay a few so I made spend a minute describing what I mean when I say simple closure is a`0:02:42`programming language it runs in the JVM and JavaScript and pretty much a substantial a subset of closure runs on JavaScript so it's a program lines with`0:02:51`which you can target both but originally it only targeted the JVM and the CLR it's they're still a port to the CLR that's maintained but does not seem C`0:03:00`wide us

[... 540597 more chars: same command with --offset 4000]
```
17. shell `fetch-text "https://web.archive.org/web/2020/https://qconlondon.com/london-2012/qconlondon.com/dl/qcon-london-2012/slides/RichHickey_SimpleMadeEasy.pdf" --max 8000` → exit 0
```text
SOURCE: https://web.archive.org/web/20220517021803/https://qconlondon.com/london-2012/qconlondon.com/dl/qcon-london-2012/slides/RichHickey_SimpleMadeEasy.pdf
TYPE: pdf
GUARD: clean (max score 0.00)
LENGTH: 0 chars (showing 0-0)

(no readable text)
```
18. shell `search "\"RichHickey_SimpleMadeEasy.pdf\"" --n 8` → exit 0
```text
no results (engines down: brave, duckduckgo, wikidata)
```
19. shell `search "\"Simple Made Easy\" Hickey slide \"adjacens\" OR \"to lie near\"" --n 8` → exit 0
```text
   https://speakerdeck.com/lagenorhynque/simple-made-easy-made-easy
   Jul 29, 2019 ... Rich Hickeyの有名なプレゼン"Simple Made Easy"を簡単に解説(*> ᴗ ... adjacens adjacens. (cf. adjacent) : ( ) ( ) ( ) / : : easy easy ease ...
7. "Simple Made Easy" Made Easier: Clojureに学ぶsimplicity | ドクセル
   https://www.docswell.com/s/lagenorhynque/K7NJ12-simple-made-easy-made-easier
   May 28, 2026 ... 11. Simple Made Easy (at Strange Loop 2011) 作者Rich Hickeyによる ... 15. easy の意味easy (= ease + -y) < aise/eise < adjacens ラテン語 adjacens ( ...
8. Simple and Easy: A Vocabulary to Describe Software Complexity
   http://daemon.co.za/2014/03/simple-and-easy-vocabulary-to-describe-software-complexity
   Mar 23, 2014 ... ... Simple Made Easy by Rich Hickey, the creator of Clojure. ... Easy, when traced down to the original latin adjacens, means 'lying close by' or 'to ...
```
20. shell `fetch-text "https://raw.githubusercontent.com/matthiasn/talk-transcripts/master/Hickey_Rich/SimpleMadeEasy-mostly-text.md" --max 12000` → exit 0
```text
supposed to do?  Can we fix problems when they arise?  And if we are
given a new requirement, can we change it?

These things have nothing to do with the construct, as we typed it in,
or very little to do with it, and have a lot to do with the attributes
of the artifact. 

[... 55163 more chars: same command with --offset 12000]
```
