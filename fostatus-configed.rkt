#lang racket

(require json)
(require xml)
(require web-server/servlet
         web-server/servlet-env)

(define servers (string->jsexpr (file->string "servers.json")))

; Probably some nicer way to do this that I don't know about yet...
(define all_servers (hash-ref (hash-ref (hash-ref servers 'fonline) 'config) 'server))

; Get server names, convert to list of strings and sort in alphanumerical order
(define names (sort (map ~a (hash-keys all_servers)) string<?))

; Get a server property, or "" if it doesn't exist
(define (server_get server)
  (hash-ref all_servers (string->symbol server))
  )


(define (server_key server key)
  (hash-ref (server_get server) key ""))
(define (server_key_exists server key)
  (hash-has-key? (server_get server) key))
; Helpers to get all properties from server x
(define (server_name server)(server_key server 'name))
(define (server_host server)(server_key server 'host))
(define (server_port server)(server_key server 'port))
(define (server_web server) (server_key server 'website))
(define (server_link server)(server_key server 'link))
(define (server_irc server)(server_key server 'irc))
(define (server_color server)(server_key server 'color))

; host:port or ""
(define (server_addr server)
  (if (server_key_exists server 'host)
      (format "~a:~a" (server_host server) (server_port server))
      ""
  )
 )

(define (html_href url text) `(a (( href ,url)) ,text))

; Link to server
;(define (server_href x) `(a (( href ,(format "/server/~a" x))) ,(server_key x 'name)) )
(define (server_href x) (html_href (format "/server/~a" x) (server_name x)))
  
(define (include_css name)
  `(link ((rel "stylesheet") (href "style.css")))
  )

(define (html_table_header elems)
  `(tr ,@(for/list ([x elems])
    `(th ,x)))
  )

(define (html_table_row cells)
`(tr ,@(for/list ([x cells])
    `(td ,x ))))

(define (html_table header rows)
  `(table (thead (,@header) ) (tbody ,@rows))
)

; Cells to show for each row.
(define (server_attrs x) 
  (list (server_href x)
        (server_addr x)
        (html_href (server_web x) (server_web x))
  )
)

;(define x (server_attrs "aftertimes"))
;x

(define server_rows (map (lambda (x) `,(html_table_row `,(server_attrs x))) names))
server_rows

(define server_table (html_table
                              (html_table_header '("Name" "IP:Port", "Website"))
                              server_rows
  ))

server_table

(define (start req)
  (response/xexpr
   `(html (head (title "FOStatus Config-ed")
                ,(include_css "style.css")) 
          (body (div ((id "content"))
                     (div ((id "edit-area" )) (p "Click on a server to edit config.")
                      ,server_table))))))


(serve/servlet start
               #:port 1500
               #:servlet-path "/"
               #:extra-files-paths (list(build-path "./static" ))
               )