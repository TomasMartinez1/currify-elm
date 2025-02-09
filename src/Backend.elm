port module Backend exposing (..)
import Types exposing(Song)

import Utils exposing (..)
import Models exposing (Model)
import List exposing (range, map, intersperse, filter, append, singleton, head)
import String exposing (concat, contains, toUpper)
import Maybe exposing (withDefault)

-- Existe la funcion findSong que recibe
-- una condicion y una lista de canciones
-- findSong : (Song -> Bool) -> List Song -> Song

-- Existe la funcion tailSafe que recibe
-- una lista de canciones y se queda con la cola
-- si la lista no tiene cola (tiene un solo elemento)
-- se queda con una lista vacia
-- tailSafe : List Song -> List Song

-- Existe idFirst que recibe una lista
-- de canciones y devuelve el id de la primera
-- idFirst : List Song -> String


-- Debería darnos la url de la cancion en base al id
urlById : String -> List Song -> String
urlById id songs = (findSong (cancionPorId id) songs ).url

cancionPorId : String -> Song -> Bool
cancionPorId id song = id == song.id

-- Debería darnos las canciones que tengan ese texto en nombre o artista
filterByName : String -> List Song -> List Song
filterByName text songs = filter (contieneTextoEnNombreOArtista text) songs
--filterByName text songs = filter (contieneTextoEnNombreOArtista text) songs

contieneTextoEnNombreOArtista : String -> Song -> Bool
contieneTextoEnNombreOArtista texto song = contains (toUpper texto) (toUpper song.name) || contains (toUpper texto) (toUpper song.artist)

-- Recibe un id y tiene que likear/dislikear una cancion
-- switchear song.liked
toggleLike : String -> List Song -> List Song
toggleLike id songs = map (switchPorId id) songs

switchPorId : String -> Song -> Song
switchPorId id song = if cancionPorId id song then switchear song else song

--switchear : Song -> Song
--switchear song = if song.liked then {song | liked = False} else {song | liked = True}

switchear : Song -> Song
switchear song = {song | liked = not (song.liked)}

-- Esta funcion tiene que decir si una cancion tiene
-- nuestro like o no, por ahora funciona mal...
-- hay que arreglarla
isLiked : Song  -> Bool
isLiked song = song.liked

-- Recibe una lista de canciones y nos quedamos solo con las que
-- tienen un like
filterLiked : List Song -> List Song
filterLiked songs = filter isLiked songs

-- Agrega una cancion a la cola de reproduccion
-- (NO es necesario preocuparse porque este una sola vez)
addSongToQueue : Song -> List Song -> List Song
addSongToQueue song queue = queue ++ (singleton song)

-- Saca una cancion de la cola
-- (NO es necesario que se elimine una sola vez si esta repetida)
removeSongFromQueue : String -> List Song -> List Song
removeSongFromQueue id queue = filter (not << cancionPorId id) queue

-- Hace que se reproduzca la canción que sigue y la saca de la cola
playNextFromQueue : Model -> Model
playNextFromQueue model = case model.queue of
                        [] -> model
                        _ -> (eliminarPrimeroDeQueueModel << playSong model) (idFirst model.queue)

eliminarPrimeroDeQueueModel : Model -> Model
eliminarPrimeroDeQueueModel model = {model | queue = tailSafe model.queue}

-------- Funciones Listas --------

-- Esta funcion recibe el modelo y empieza a reproducir la
-- cancion que tenga el id que se pasa...
-- Mirar la función urlById
playSong : Model -> String -> Model
playSong model id = { model | playerUrl = urlById id model.songs, playing = (if id /= "" then Just True else Nothing) }

applyFilters : Model -> List Song
applyFilters model =
  model.songs
    |> filterByName model.filterText
    |> if model.onlyLiked then filterLiked else identity

port togglePlay : Bool -> Cmd msg
port songEnded : (Bool -> msg) -> Sub msg