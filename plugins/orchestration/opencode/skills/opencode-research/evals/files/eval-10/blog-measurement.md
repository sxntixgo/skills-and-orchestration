# I measured SearXNG's memory so you don't have to
*Posted 2025-06-14 on a personal blog (fictional eval fixture)*

I ran SearXNG in Docker on a Raspberry Pi 4 for a week with three users.
At idle the container used about 85 MB of RAM; under a burst of 20 searches it peaked at 160 MB.
Your numbers will differ with the number of engines and uWSGI workers you enable.
