% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sessions.R, R/sessionsDoc.R
\name{newSession}
\alias{newSession}
\title{Create a new session.}
\usage{
newSession(remDr, ...)
}
\arguments{
\item{remDr}{An object of class "rDriver". A remote driver object see
\code{\link{remoteDr}}.}

\item{...}{Additonal function arguments - Currently passes the
\code{\link{retry}} argument.}
}
\value{
invisible(remDr): An object of class "rDriver" is invisibly
   returned. A remote driver object see \code{\link{remoteDr}}. This
   allows for chaining from this function to other functions that take
   such an object as an argument. See examples for further details.
}
\description{
\code{newSession} The server should attempt to create a session that
   most closely matches the desired and required capabilities. Required
   capabilities have higher priority than desired capabilities and must
   be set for the session to be created.
}
\examples{
\dontrun{
  # start a driver without opening a browser
  remDr <- remoteDr(newSession = FALSE)

  # open a broswer
  remDr \%>\% newSession

  # set timeout on waiting for elements
  remDr \%>\% setTimeout(type = "implicit", 5000)

  # close Session
  remDr \%>\% deleteSession

}

}
\seealso{
Other sessions functions: \code{\link{deleteSession}},
  \code{\link{getTimeouts}}, \code{\link{setTimeouts}},
  \code{\link{status}}
}

