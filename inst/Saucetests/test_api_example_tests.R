context("api_example_tests")
if(identical(TRUE, getOption("seleniumPipes_SL"))){
  # sauce labs test
  pv <- packageVersion("seleniumPipes")
  slFlags <- list(name = "seleniumPipes-test-suite"
                  , build = sum(unlist(pv)*10^(3-seq_along(unlist(pv))))
                  , tags =  list("api-example")
                  , "custom-data" =
                    list(release = do.call(paste,
                                           list(pv, collapse = "."))

                    )
  )
  selOptions <- getOption("seleniumPipes_selOptions")
  selOptions$extraCapabilities <- c(selOptions$extraCapabilities, slFlags)
  options(seleniumPipes_selOptions = selOptions)
}

source(file.path(find.package("seleniumPipes"), "Saucetests", 'setup.R'),
       local = TRUE)
on.exit(remDr %>% deleteSession())

#1
test_that("GetTitle", {
  title <- remDr %>% go(loadPage("simpleTest")) %>%
    getTitle()
  expect_equal("Hello WebDriver", title)
}
)

#2
test_that("GetCurrentUrl", {
  getCurrentUrl <- remDr %>% go(loadPage("simpleTest")) %>%
    getCurrentUrl()
  expect_equal(loadPage("simpleTest"), getCurrentUrl)
}
)

#3
test_that("FindElementsByXPath", {
  findElementText <- remDr%>% go(loadPage("simpleTest")) %>%
    findElement(using = "xpath", "//h1") %>% getElementText()

  expect_equal("Heading", findElementText)
}
)

#4-5
test_that("FindElementByXpathThrowNoSuchElementException", {
  expect_error(
    findElementText <- remDr%>% go(loadPage("simpleTest")) %>%
      findElement(using = "xpath", "//h4", retry = FALSE) %>%
      getElementText()
  )
  expect_equal(7, errorContent()$status)
}
)

#6-7
test_that("FindElementsByXpath", {
  elems <- remDr %>% go(loadPage("nestedElements")) %>%
    findElements(using = "xpath", "//option")
  expect_equal(48, length(elems))
  expect_equal("One", elems[[1]] %>% getElementAttribute("value"))
}
)

#8
test_that("FindElementsByName", {
  elem <- remDr %>% go(loadPage("xhtmlTest")) %>%
    findElement(using = "name", "windowOne")
  expect_equal("Open new window", elem %>% getElementText)
}
)

#9
test_that("FindElementsByNameInElementContext", {
  childElem <- remDr %>% go(loadPage("nestedElements")) %>%
    findElement(using = "name", "form2") %>%
    findElementFromElement(using = "name", "selectomatic")
  Sys.sleep(2)
  expect_equal("2", childElem %>% getElementAttribute("id"))
}
)

#10
test_that("FindElementsByLinkTextInElementContext", {
  childElem <- remDr %>% go(loadPage("nestedElements")) %>%
    findElement(using = "name", "div1") %>%
    findElementFromElement(using = "link text", "hello world")
  Sys.sleep(2)
  expect_equal("link1", childElem %>% getElementAttribute("name"))
}
)

#11
test_that("FindElementByIdInElementContext", {
  childElem <- remDr %>% go(loadPage("nestedElements")) %>%
    findElement(using = "name", "form2") %>%
    findElementFromElement(using = "id", "2")
  Sys.sleep(2)
  expect_equal("selectomatic", childElem %>% getElementAttribute("name"))
}
)

#12
test_that("FindElementByXpathInElementContext", {
  childElem <- remDr %>% go(loadPage("nestedElements")) %>%
    findElement(using = "name", "form2") %>%
    findElementFromElement(using = "xpath", "select")
  Sys.sleep(2)
  expect_equal("2", childElem %>% getElementAttribute("id"))
}
)

#13-14
test_that("FindElementByXpathInElementContextNotFound", {
  expect_error(remDr %>% go(loadPage("nestedElements")) %>%
                 findElement(using = "name", "form2") %>%
                 findElementFromElement(using = "xpath", "div",
                                        retry = FALSE))
  expect_equal(7, errorContent()$status)
}
)

#15
test_that("ShouldBeAbleToEnterDataIntoFormFields", {
  elem <- remDr %>% go(loadPage("xhtmlTest")) %>%
    findElement(using = "xpath",
                "//form[@name='someForm']/input[@id='username']") %>%
    elementClear() %>%
    elementSendKeys("some text")
  elem <- remDr %>%
    findElement(using = "xpath",
                "//form[@name='someForm']/input[@id='username']")
  expect_equal("some text", elem %>% getElementAttribute("value"))
}
)

#16-17
test_that("FindElementByTagName", {
  elems <-remDr %>% go(loadPage("simpleTest")) %>%
    findElements(using = "tag name", "div")
  num_by_xpath <- length(remDr %>% findElements(using = "xpath", "//div"))
  expect_equal(num_by_xpath, length(elems))
  elems <- remDr %>% findElements(using = "tag name", "iframe")
  expect_equal(0, length(elems))
}
)

#18
test_that("FindElementByTagNameWithinElement", {
  elems <- remDr %>% go(loadPage("simpleTest")) %>%
    findElement(using = "id", "multiline") %>%
    findElementsFromElement(using = "tag name", "p")
  expect_true(length(elems) == 1)
}
)

#19-21
test_that("SwitchToWindow", {
  #if(rdBrowser == 'safari'){
  # see https://code.google.com/p/selenium/issues/detail?id=3693
  #return()
  #}
  title_1 <- "XHTML Test Page"
  title_2 <- "We Arrive Here"

  remDr %>% go (loadPage("xhtmlTest")) %>%
    findElement(using = "link text", "Open new window") %>% elementClick()
  expect_equal(title_1, remDr %>% getTitle)
  Sys.sleep(5)
  remDr %>% switchToWindow("result")
  #         wait.until(lambda dr: dr.switch_to_window("result") is None)
  expect_equal(title_2, remDr %>% getTitle)
  # close window and switch back to first one
  chk <- tryCatch({
    windows <- unlist(remDr %>% getWindowHandles(retry = FALSE))
    currentWindow <- remDr %>% getWindowHandle(retry = FALSE)
    remDr %>% closeWindow() %>%
      switchToWindow(windows[!windows %in% currentWindow])
  }, error = function(e) e)
  if(inherits(chk, "simpleError")){
    # try old functions
    windows <- unlist(remDr %>% getWindowHandlesOld)
    currentWindow <- remDr %>% getWindowHandleOld
    remDr %>% closeWindow() %>%
      switchToWindow(windows[!windows %in% currentWindow])
  }
  expect_equal(title_1, remDr %>% getTitle)
}
)

####
test_that("SwitchFrameByName", {
  remDr %>% go(loadPage("frameset")) %>%
    switchToFrame("third") %>% findElement(using = "id", "checky") %>%
    elementClick()
}
)

#22-23
test_that("IsEnabled", {
  elem <- remDr %>% go(loadPage("formPage")) %>%
    findElement(using = "xpath", "//input[@id='working']")
  expect_true(elem %>% isElementEnabled)
  elem <- remDr %>% findElement(using = "xpath",
                                "//input[@id='notWorking']")
  expect_false(elem %>% isElementEnabled)
}
)

#24-27
test_that("IsSelectedAndToggle", {
  if(rdBrowser == 'chrome' &&
     package_version(remDr$sessionInfo$version)$major < 16){
    return("deselecting preselected values only works on chrome >= 16")
  }
  elem <- remDr %>% go(loadPage("formPage")) %>%
    findElement(using = "id", "multi")
  option_elems <-  elem %>%
    findElementsFromElement(using = "xpath", "option")
  Sys.sleep(2)
  expect_true(option_elems[[1]] %>% isElementSelected)
  option_elems[[1]] %>% elementClick
  Sys.sleep(2)
  expect_false(option_elems[[1]] %>% isElementSelected)
  option_elems[[1]] %>% elementClick
  Sys.sleep(2)
  expect_true(option_elems[[1]] %>% isElementSelected)
  expect_true(option_elems[[3]] %>% isElementSelected)
}
)

#28-30
test_that("Navigate", {
  # if(rdBrowser == 'safari'){
  # return()
  # }

  remDr %>% go(loadPage("formPage")) %>%
    findElement(using = "id", "imageButton") %>% elementClick
  expect_equal("We Arrive Here", remDr %>% getTitle)
  remDr %>% seleniumPipes::back()
  expect_equal("We Leave From Here", remDr %>% getTitle)
  remDr %>% forward()
  expect_equal("We Arrive Here", remDr %>% getTitle)
}
)

#31
test_that("GetAttribute", {
  attr <- remDr %>% go(loadPage("xhtmlTest")) %>%
    findElement(using = "id", "id1") %>% getElementAttribute("href")
  expect_equal(paste0(loadPage("xhtmlTest"), "#"), attr)
}
)

#32-36
test_that("GetImplicitAttribute", {
  elems <- remDr %>% go(loadPage("nestedElements")) %>%
    findElements(using = "xpath", "//option")
  expect_true(length(elems) >= 3)
  for(x in seq(4)){
    expect_equal(x-1, as.integer(elems[[x]] %>%
                                   getElementAttribute("index")))
  }
}
)

#37
test_that("ExecuteSimpleScript", {
  chk <- tryCatch({
    title <- remDr %>% go(loadPage("xhtmlTest")) %>%
      executeScript("return document.title;", retry = FALSE)
  }, error = function(e) e)
  if(inherits(chk, "simpleError")){
    # try old functions
    title <- remDr %>% go(loadPage("xhtmlTest")) %>%
      executeScriptOld("return document.title;")
  }
  expect_equal("XHTML Test Page", title)
}
)

#38
test_that("ExecuteScriptAndReturnElement", {
  chk <- tryCatch({
    elem <- remDr %>% go(loadPage("xhtmlTest")) %>%
      executeScript("return document.getElementById('id1');",
                    retry = FALSE)
  }, error = function(e) e)
  if(inherits(chk, "simpleError")){
    # try old functions
    elem <- remDr %>% go(loadPage("xhtmlTest")) %>%
      executeScriptOld("return document.getElementById('id1');")
  }
  expect_identical("wElement", class(elem))
}
)

#39
test_that("ExecuteScriptWithArgs", {
  chk <- tryCatch({
    jS <- "return arguments[0] == 'fish' ? 'fish' : 'not fish';"
    result <- remDr %>% go(loadPage("xhtmlTest")) %>%
      executeScript(jS, list("fish")
                    , retry = FALSE)
  }, error = function(e) e)
  if(inherits(chk, "simpleError")){
    # try old functions
    jS <- "return arguments[0] == 'fish' ? 'fish' : 'not fish';"
    result <- remDr %>% go(loadPage("xhtmlTest")) %>%
      executeScriptOld(jS, list("fish"))
  }
  expect_equal("fish", result)
}
)

#40
test_that("ExecuteScriptWithMultipleArgs", {
  chk <- tryCatch({
    result <- remDr %>% go(loadPage("xhtmlTest")) %>%
      executeScript("return arguments[0] + arguments[1]", list(1, 2)
                    , retry = FALSE)
  }, error = function(e) e)
  if(inherits(chk, "simpleError")){
    # try old functions
    result <- remDr %>% go(loadPage("xhtmlTest")) %>%
      executeScriptOld("return arguments[0] + arguments[1]", list(1, 2))
  }
  expect_equal(3, result)
}
)

#41
test_that("ExecuteScriptWithElementArgs", {
  chk <- tryCatch({
    button <- remDr %>% go(loadPage("javascriptPage")) %>%
      findElement(using = "id", "plainButton")
    appScript <-
      "arguments[0]['flibble'] = arguments[0].getAttribute('id');
        return arguments[0]['flibble'];"
    result <- remDr %>% executeScript(appScript, list(button),
                                      retry = FALSE)
  }, error = function(e) e)
  if(inherits(chk, "simpleError")){
    # try old functions
    button <- remDr %>% go(loadPage("javascriptPage")) %>%
      findElement(using = "id", "plainButton")
    appScript <-
      "arguments[0]['flibble'] = arguments[0].getAttribute('id');
        return arguments[0]['flibble'];"
    result <- remDr %>% executeScriptOld(appScript, list(button))
  }
  expect_equal("plainButton", result)
}
)

#42
test_that("FindElementsByPartialLinkText", {
  elem <- remDr %>% go(loadPage("xhtmlTest")) %>%
    findElement(using = "partial link text", "new window")
  expect_equal("Open new window", elem %>% getElementText)
}
)

#43-44
test_that("IsElementDisplayed", {
  visible <- remDr %>% go(loadPage("javascriptPage")) %>%
    findElement(using = "id", "displayed") %>%
    getElementCssValue("visibility")
  not_visible <- remDr %>% findElement(using = "id", "hidden")%>%
    getElementCssValue("visibility")
  expect_identical(visible, "visible")
  expect_identical(not_visible, "hidden")
}
)

#45-46
test_that("MoveWindowPosition", {
  # not implemented for now
  return()
  if(rdBrowser == 'android' || rdBrowser == "safari"){
    print("Not applicable")
    return()
  }
  return()
  loc <- remDr %>% go(loadPage("blank")) %>%
    getWindowPosition()
  # note can't test 0,0 since some OS's dont allow that location
  # because of system toolbars
  new_x <- 50
  new_y <- 50
  if(loc[['x']] == new_x){
    new_x <- new_x + 10
  }
  if(loc['y'] == new_y){
    new_y <- new_y + 10
  }
  remDr %>% setWindowPosition(new_x, new_y)
  loc <- remDr %>% getWindowPosition()
  # change test to be within 10 pixels
  expect_less_than(abs(loc[['x']] - new_x), 10)
  expect_less_than(abs(loc[['y']] - new_y), 10)
}
)

#47-48
test_that("ChangeWindowSize", {
  # not currently implemented
  return()
  if(rdBrowser == 'android'){
    print("Not applicable")
    return()
  }
  return()
  size <- remDr %>% go(loadPage("blank")) %>%
    getWindowSize()
  newSize <- rep(600, 2)
  if( size[['width']] == 600){
    newSize[1] <- 500
  }
  if( size[['height']] == 600){
    newSize[2] <- 500
  }
  remDr %>% setWindowSize(newSize[1], newSize[2])
  size <- remDr %>% getWindowSize()
  # change test to be within 10 pixels
  expect_less_than(abs(size[['width']] - newSize[1]), 10)
  expect_less_than(abs(size[['height']] - newSize[2]), 10)
}
)
