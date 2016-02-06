module Releases
  ( Release
  , latestVersion
  , release
  , needsUpdate
  )
  where


import String
import Task
import Http
import Json.Decode as Decode exposing ((:=))


type alias Release =
  { version : String
  , url : String
  }


release : String -> Release
release version =
  let
    urlGuess =
      "https://github.com/TroopTrack/trooptrack-photo-sync/releases/tag/" ++ version

  in
    Release version urlGuess


needsUpdate : Release -> Maybe Release -> Maybe Release
needsUpdate current maybeSpeculative =
  case maybeSpeculative of
    Nothing -> Nothing
    Just speculative ->
      if (semver current.version) `isEarlierVersionOf` (semver speculative.version)
        then Just speculative
        else Nothing


isEarlierVersionOf : List comparable -> List comparable -> Bool
isEarlierVersionOf v1 v2 =
  List.map2 compare v1 v2
    |> isUpate


semver : String -> List Int
semver versionString =
  let
    justNumbers =
      if (String.left 1 versionString) == "v"
        then String.dropLeft 1 versionString
        else versionString

    intMe s =
      String.toInt s
        |> Result.withDefault 0
  in
    justNumbers
      |> String.split "."
      |> List.map intMe


isUpate : List Order -> Bool
isUpate orders =
  case orders of
    [] -> False
    GT :: _ -> False
    LT :: _ -> True
    EQ :: rest -> isUpate rest




latestVersion : Task.Task Http.Error Release
latestVersion =
  Http.get decodeRelease "https://api.github.com/repos/TroopTrack/trooptrack-photo-sync/releases/latest"


decodeRelease : Decode.Decoder Release
decodeRelease =
  Decode.object2 Release
    ("tag_name" := Decode.string)
    ("html_url" := Decode.string)
