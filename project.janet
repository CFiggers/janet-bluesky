(declare-project
  :name "bluesky"
  :author "Caleb Figgers"
  :description "A simple CLI for posting to Bluesky."
  :dependencies ["https://git.sr.ht/~pepe/shriek"
                 "https://github.com/ianthehenry/cmd"
                 "https://github.com/janet-lang/spork"]) 
   
(declare-executable
  :name "bluesky"
  :entry "src/bluesky.janet"
  :cflags ["-s"]
  :install true)