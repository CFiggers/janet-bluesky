# bluesky

A CLI utility for posting to [Bluesky](https://bsky.app), written in [Janet](https://github.com/janet-lang/janet).

## Getting Started 

Requires [janet](https://www.janet-lang.org) and [jpm](https://github.com/janet-lang/jpm).

1. Clone this repository (e.g. `$ gh repo clone CFiggers/bluesky`) and change directories into the newly-cloned repo (e.g. `$ cd bluesky`).

2. Install dependencies using jpm (run `$ jpm deps`).

3. Run the program, either as an interpreted script (e.g. `janet src/bluesky.janet`) or by compiling a stand-alone binary first (e.g. `jpm build` and then `./build/bluesky`).

4. Set up an App Password in your Bluesky account

5. Pass your Bluesky username and App Password to the program in one of the following ways:
   - Pass `--username` and `--password` as CLI parameters
   - Set `BLUESKY_USERNAME` and `BLUESKY_APP_PASSWORD` environment variables (recommended)
   - Type or paste in when prompted 

6. Post to Bluesky! (e.g. `bluesky --text "Hello, world! I posted this via the API."`)
