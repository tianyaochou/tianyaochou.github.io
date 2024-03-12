--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import Hakyll
import Hakyll.EDE
import Helper
import Data.Aeson as A

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
  match "images/*" $ do
    route idRoute
    compile copyFileCompiler

  match "css/*" $ do
    route idRoute
    compile compressCssCompiler

  match (fromList ["contact.markdown"]) $ do
    route $ setExtension "html"
    compile $
      pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls

  match "resume/index.md" $ do
    route $ setExtension "html"
    compile $ do
      dataJson <- loadBody (fromFilePath "resume/resume.json")
      ctx <- fromObject dataJson
      applySelfEdeTemplate ctx
        >>= renderPandoc
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls
  
  match "**.json" $ do
    compile $ do
      content <- getResourceLBS
      json <- liftMaybe "Parse json failed" ((A.decode $ itemBody content) :: Maybe Value)
      makeItem json

  match "posts/*" $ do
    route $ setExtension "html"
    compile $
      pandocCompiler
        >>= loadAndApplyTemplate "templates/blog/post.html" postCtx
        >>= loadAndApplyTemplate "templates/default.html" postCtx
        >>= relativizeUrls

  create ["blog/index.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx =
            listField "posts" postCtx (return posts)
              `mappend` constField "title" "Posts"
              `mappend` defaultContext

      makeItem ""
        >>= loadAndApplyTemplate "templates/blog/index.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let indexCtx =
            listField "posts" postCtx (return posts)
              `mappend` constField "title" "Home"
              `mappend` defaultContext

      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls

  match "CNAME" $ do
    route idRoute
    compile copyFileCompiler

  match "templates/ede/**" $ compile edeTemplateCompiler
  match "templates/**" $ compile templateCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
  dateField "date" "%B %e, %Y"
    `mappend` defaultContext
