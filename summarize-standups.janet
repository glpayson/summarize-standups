#!/usr/bin/env janet

(def base-dir 
  (if-let [dir (os/getenv "DAILIES_DIR")]
    dir
    (do 
      (print "Error: DAILIES_DIR environment variable must be set")
      (os/exit 1))))

(def out-dir 
  (if-let [dir (os/getenv "SPRINTS_DIR")]
    dir
    (do 
      (print "Error: SPRINTS_DIR environment variable must be set")
      (os/exit 1))))

(defn write-summary
  "Write LLM summary to disk."
  [summary end] 
  (let [fname (first (string/split "." (last (string/split "/" (get end :file)))))
        out-file (string out-dir "/" fname "-summary.md")]
    (spit out-file summary)))

(defn run-fabric-summary
  "Call Fabric to summarize standups."
  [text]
  (def [stdin-r stdin-w] (os/pipe))
  (def [stdout-r stdout-w] (os/pipe))

  # write the input that will be sent
  (:write stdin-w text)
  (:close stdin-w)
  
  (os/execute ["fabric" "--pattern" "summarize_standups"]
              :px
              # the program reads from :in and writes to :out
              {:in stdin-r :out stdout-w})
              
  (:read stdout-r math/int32-max))

(defn extract-standups
  "Extract all standup sections from files."
  [files]
  (var collecting false)
  (var standups @[])
  (each file files
    (let [lines (string/split "\n" (slurp file))]
      (each line lines
        (cond
          # Start collecting when we hit the standup section
          (string/has-prefix? "## Standup" line)
          (set collecting true)
      
          # Stop collecting when we hit the separator
          (= "---" line)
          (set collecting false)
      
          # If we're in collecting mode, add the line
          collecting
          (array/push standups line)))))
  (string/join standups "\n"))

(defn filter-files 
  "Keep files that are between the start and end date."
  [files start end]
  (let [start-file (get start :file)
        end-file (get end :file)]
   (var filtered files) 
   (filter (fn [file] 
             (let [fname (first (string/split "." (last (string/split "/" file))))]
                (and (>= fname start-file) 
                     (<= fname end-file))))
           filtered)))

(defn get-files
  "Get all files in folders."
  [folders]
  (var files @[]) 
    (each folder folders
      (let [folder-files (os/dir folder)]
        (array/concat files 
          (map (fn [f] (string folder "/" f)) folder-files))))
    files)

(defn get-folders 
  "Get daily folders between start and end date."
  [start end]
  (let [end-year (scan-number (get end :year))
        end-month (scan-number (get end :month))]
    (var year-counter (scan-number (get start :year)))
    (var month-counter (scan-number (get start :month)))
    (var folders @[])

    (while (and (<= year-counter end-year) 
            (or (< year-counter end-year)
                (<= month-counter end-month)))
      (array/push folders (string base-dir "/" year-counter "/" (string/format "%02d" month-counter)))
      (if (< month-counter 12)
        (++ month-counter)
        (do 
          (set month-counter 1)
          (++ year-counter))))
    folders))

(defn adjust-start-year
  "Decrement the start year if the start date was last year."
  [start end]
  (var start-date start)
  (let [start-month (get start-date :month)
        start-year (get start-date :year)
        end-month (scan-number (get end :month))]
    (if (> start-month end-month)
      (set start-date (put start-date :year (- start-year 1))))
    start-date))

(defn string-date 
  "Convert date to string and add the name of the daily markdown file."
  [date]
  (let [year (string (get date :year))
        month (string/format "%02d" (get date :month))
        date (string/format "%02d" (get date :date))]
    {:year year
     :month month
     :date date
     :file (string year "-" month "-" date ".md")}))

(defn get-date
  "Split the input into date parts. If the year wasn't specified then assume it is this year (it will be adjusted later in the case that it was last year)."
  [date]
  (let [date-parts (string/split  "/" date)]
    (if (= 3 (length date-parts))
      {:year (scan-number (get date-parts 0))
       :month (scan-number (get date-parts 1))
       :date (scan-number (get date-parts 2))}     
      @{:year (get (os/date) :year)
       :month (scan-number (get date-parts 0))
       :date (scan-number (get date-parts 1))})))

(defn get-dates 
  "Convert input into date information."
  [start end]
  (let [end-date (-> end get-date string-date)
        start-date (-> start get-date (adjust-start-year end-date) string-date)]
    [start-date end-date]))

(defn main
  "Read all Obsidian daily files between start and end date, extract the standup sections, send them to an LLM for summarization, and write the summary to disk."
  [& args]
  (let [start (get args 1)
        end (get args 2)]
    (let [[start-date end-date] (get-dates start end)]
      (-> (get-folders start-date end-date)
          get-files
          (filter-files start-date end-date)
          extract-standups
          run-fabric-summary
          (write-summary end-date)))))

#(main "script-name" "11/24" "12/16")
