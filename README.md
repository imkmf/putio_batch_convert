put.io batch converter
===

A simple Ruby script for batch converting Put.io files to MP4.

---

Problem: A put.io download finishes and it's entirely non-MP4 files (MKV, AVI, etc.)

Converting to MP4, according to put.io, takes half the length of the file. This is a limitation of ffmpeg or whatever put.io uses behind the scenes to convert their files.

Solution: We save time by starting these conversions automatically. Instead of opening files on your Roku or other MP4-handling device to find that you have to convert (and wait), we can load them all up into put.io's queue and be proactive. Woot!

"So is this okay, API-wise?" Well... I think so. put.io queues conversions, but in [their FAQ](http://faq.put.io/#convertall), they state that they're not super into the idea of converting whole folders. Note that I've been clicking through entire folders and loading up conversions for literally years now, so I think this is okay.

If you're from put.io and this *isn't* okay, [contact me (mailto link)](mailto:kristian@kristianfreeman.com).

---

Config: API key in `.secrets`:

```
API_KEY=12345678
```

