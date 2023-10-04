(import shriek :as http)
(import json)
(import cmd)

(defn request [method url &opt copts mimes]
  (default copts {})
  (def [bb hb] [@"" @""])
  (def opts (merge @{:method method
                     :url url
                     :write-function (fn [buf] (buffer/push bb buf))
                     :header-function (fn [buf] (buffer/push hb buf))} copts))
  (def curl (:setopt (http/init) ;(kvs opts)))

  (if mimes (:add-mime curl mimes))
  (:perform curl)
  # TODO peg from spork
  (def headers
    (->> (slice (string/split "\r\n" hb) 1)
         (filter |(not (empty? $)))
         (map |(string/split ": " $ 0 2))
         flatten
         (apply struct)))
  @{:status (:getinfo curl :response-code)
    :body (string bb)
    :headers headers})

(defn get-accessJwt [username app-password &opt debug-print]
  (let [url "https://bsky.social/xrpc/com.atproto.server.createSession"
        data (string (json/encode
                      {"identifier" username
                       "password" app-password}))
        response-map (json/decode
                      (get (request "POST" url
                                    {:http-headers ["content-type: application/json"]
                                     :post-fields data})
                           :body) true)]
    (when debug-print (eprintf "Tried to get a JWT, Received this response: %q" response-map))
    (response-map :accessJwt)))

(defn post! [username text token &opt debug-print]
  (let [url "https://bsky.social/xrpc/com.atproto.repo.createRecord"
        record {"text" text 
                "createdAt" (os/strftime "%Y-%m-%dT%H:%M:%SZ")}
        data (string
              (json/encode
               {"repo" username
                "collection" "app.bsky.feed.post"
                "record" record})) 
        response (request "POST"
                          url
                          {:http-headers ["content-type: application/json"
                                          (string "Authorization: Bearer " token)]
                           :post-fields data})] 
    (when debug-print
      (eprintf "Tried to post to Bluesky, got this reponse: %q" response))
    response))

(defn send-post! [username token text &opt debug-print]
  (eprint "Trying to send a post") 
  (if-let [response (post! username text token debug-print)]
    (do (eprint "  Got a response\n")
        (if (= (response :status) 200)
          (eprint "Seems like that worked!")
          (do (eprint "Seems like that didn't work.")
              (quit 1))))
    (do (eprint "Didn't get a response for some reason.")
        (quit 1))))

(defn get-token [username app-password &opt debug-print] 
  (eprint "Trying to get a token")
  (if-let [token (get-accessJwt (string username) (string app-password) debug-print)]
    (do (eprint "  Got a token\n")
        token)
    (do (eprint "Couldn't get a token!")
        (quit 1))))

(defn get-username [debug-print]
  (eprint "Trying to get Username from environment")
  (let [username (or ((os/environ) "BLUESKY_USERNAME")
                         (string/slice (getline "Please type in or paste your Bluesky Username.\n") 0 -2))]
    (if username
      (do (eprint "  Got Username\n")
          username)
      (do (eprint "Couldn't get username!")
          (quit 1)))))

(defn get-app-password [debug-print]
  (eprint "Trying to get App Password from environment")
  (let [app-password (or ((os/environ) "BLUESKY_APP_PASSWORD")
                         (string/slice (getline "Please type in or paste your App Password.\n") 0 -2))]
    (if app-password
      (do (eprint "  Got App Password\n")
          app-password)
      (do (eprint "  Couldn't get app password!")
          (quit 1)))))

(cmd/main 
 (cmd/fn
   [--text :string "The text to post on Bluesky"
    --username (optional :string) "The username to use when posting on Bluesky"
    --password (optional :string) "The App Password to use when posting on Bluesky"
    [-d --debug] (flag) "Whether or not to print responses received over HTTP for debug purposes"]
   (assert (<= (length text) 300) "your message is too long to post on Bluesky (300 chr limit).") 
   (let [usern (or username (get-username debug))
         passw (or password (get-app-password debug))
         token (get-token usern passw debug)]
     (send-post! usern token text debug))))
