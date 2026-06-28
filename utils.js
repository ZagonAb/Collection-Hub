// Collection Hub Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/
function saveCustomCollections(collections) {
    api.memory.set('customCollections', collections);
}

function loadCustomCollections() {
    var collections = api.memory.get('customCollections') || [];
    collections.sort(function(a, b) {
        return (a.name || "").localeCompare(b.name || "");
    });
    return collections;
}

function getGamePath(game) {
    if (!game) return null;
    if (game.files && game.files.count > 0) {
        var f = game.files.get(0);
        if (f && f.path) return f.path;
    }
    if (game.files && game.files.path) {
        return game.files.path;
    }
    return null;
}

function addGameToCollection(collectionId, game) {
    var collections = loadCustomCollections();
    var gamePath = getGamePath(game);

    for (var i = 0; i < collections.length; i++) {
        if (collections[i].id === collectionId) {
            var alreadyAdded = false;

            for (var j = 0; j < collections[i].games.length; j++) {
                var existingGame = collections[i].games[j];

                if (gamePath && existingGame.filePath && existingGame.filePath === gamePath) {
                    alreadyAdded = true;
                    break;
                }
                if (existingGame.title === game.title) {
                    alreadyAdded = true;
                    break;
                }
                if (existingGame.gameId && game.extra && game.extra.id) {
                    if (existingGame.gameId.toString() === game.extra.id.toString()) {
                        alreadyAdded = true;
                        break;
                    }
                }
            }

            if (!alreadyAdded) {
                var gameId = gamePath || game.title;
                if (!gamePath && game.extra && game.extra.id) {
                    gameId = game.extra.id.toString();
                }

                var systemCollections = [];
                if (game.collections && game.collections.count > 0) {
                    for (var k = 0; k < game.collections.count; k++) {
                        var coll = game.collections.get(k);
                        if (coll && coll.name) {
                            systemCollections.push(coll.name);
                        }
                    }
                }

                collections[i].games.push({
                    title: game.title,
                    filePath: gamePath || "",
                    gameId: gameId,
                    developer: game.developer || "",
                    year: game.releaseYear || 0,
                    favorite: game.favorite || false,
                    systemCollections: systemCollections
                });
                saveCustomCollections(collections);
                return true;
            }
            break;
        }
    }
    return false;
}

function removeGameFromCollection(collectionId, gameTitle, gamePath) {
    var collections = loadCustomCollections();

    for (var i = 0; i < collections.length; i++) {
        if (collections[i].id === collectionId) {
            var newGames = [];
            for (var j = 0; j < collections[i].games.length; j++) {
                var g = collections[i].games[j];
                var matchByPath = gamePath && g.filePath && g.filePath === gamePath;
                var matchByTitle = g.title === gameTitle;
                if (!matchByPath && !matchByTitle) {
                    newGames.push(g);
                }
            }
            collections[i].games = newGames;
            saveCustomCollections(collections);
            return true;
        }
    }
    return false;
}

function createCollection(name) {
    var collections = loadCustomCollections();
    var newId = 1;

    if (collections.length > 0) {
        var maxId = 0;
        for (var i = 0; i < collections.length; i++) {
            if (collections[i].id > maxId) {
                maxId = collections[i].id;
            }
        }
        newId = maxId + 1;
    }

    collections.push({
        id: newId,
        name: name,
        games: []
    });

    saveCustomCollections(collections);
    return newId;
}

function removeCollection(collectionId) {
    var collections = loadCustomCollections();
    var filtered = [];

    for (var i = 0; i < collections.length; i++) {
        if (collections[i].id !== collectionId) {
            filtered.push(collections[i]);
        }
    }

    saveCustomCollections(filtered);
    return filtered;
}

function isGameInCollection(collectionId, game) {
    var collections = loadCustomCollections();
    var gamePath = (typeof game === "object" && game !== null) ? getGamePath(game) : null;
    var gameTitle = (typeof game === "object" && game !== null) ? game.title : game;

    for (var i = 0; i < collections.length; i++) {
        if (collections[i].id === collectionId) {
            for (var j = 0; j < collections[i].games.length; j++) {
                var g = collections[i].games[j];
                if (gamePath && g.filePath && g.filePath === gamePath) return true;
                if (g.title === gameTitle) return true;
            }
            break;
        }
    }
    return false;
}

function launchGameFromCollection(gameTitle) {
    for (var i = 0; i < api.allGames.count; i++) {
        var game = api.allGames.get(i);
        if (game.title === gameTitle) {
            game.launch();
            return true;
        }
    }

    for (var i = 0; i < api.collections.count; i++) {
        var collection = api.collections.get(i);
        for (var j = 0; j < collection.games.count; j++) {
            var game = collection.games.get(j);
            if (game.title === gameTitle) {
                game.launch();
                return true;
            }
        }
    }

    return false;
}

function getNameCollecForGame(game) {
    if (game && game.collections && game.collections.count > 0) {
        var firstCollection = game.collections.get(0);
        for (var i = 0; i < api.collections.count; ++i) {
            var collection = api.collections.get(i);
            if (collection.name === firstCollection.name) {
                return collection.name;
            }
        }
    }
    return "default";
}

function renameCollection(collectionId, newName) {
    var collections = loadCustomCollections();
    for (var i = 0; i < collections.length; i++) {
        if (collections[i].id === collectionId) {
            if (collections[i].name === newName) return false;
            collections[i].name = newName;
            saveCustomCollections(collections);
            return true;
        }
    }
    return false;
}

function cleanAndSplitGenres(genreText) {
    if (!genreText) return [];

    var separators = [",", "/", "-", "&", "|", ";"];
    var allParts = [genreText];

    for (var i = 0; i < separators.length; i++) {
        var separator = separators[i];
        var newParts = [];

        for (var j = 0; j < allParts.length; j++) {
            var part = allParts[j];
            var splitParts = part.split(separator);
            for (var k = 0; k < splitParts.length; k++) {
                newParts.push(splitParts[k]);
            }
        }
        allParts = newParts;
    }

    var cleanedParts = [];
    for (var l = 0; l < allParts.length; l++) {
        var cleaned = allParts[l].trim();
        if (cleaned.length > 0 &&
            cleaned.toLowerCase() !== "and" &&
            cleaned.toLowerCase() !== "or" &&
            cleaned.toLowerCase() !== "game" &&
            cleaned.length > 2) {
            cleanedParts.push(cleaned);
            }
    }

    return cleanedParts;
}

function formatPlayTime(seconds) {
    if (!seconds || seconds <= 0) return "00:00:00";
    var h = Math.floor(seconds / 3600);
    var m = Math.floor((seconds % 3600) / 60);
    var s = Math.floor(seconds % 60);
    return (h < 10 ? "0" + h : h) + ":" +
           (m < 10 ? "0" + m : m) + ":" +
           (s < 10 ? "0" + s : s);
}

function toggleGameFavorite(gameTitle) {
    for (var i = 0; i < api.allGames.count; i++) {
        var game = api.allGames.get(i);
        if (game.title === gameTitle) {
            game.favorite = !game.favorite;
            return game.favorite;
        }
    }
    return null;
}
