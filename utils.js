
function saveCustomCollections(collections) {
    api.memory.set('customCollections', collections);
}

function loadCustomCollections() {
    return api.memory.get('customCollections') || [];
}

function addGameToCollection(collectionId, game) {
    var collections = loadCustomCollections();

    for (var i = 0; i < collections.length; i++) {
        if (collections[i].id === collectionId) {
            var alreadyAdded = false;
            for (var j = 0; j < collections[i].games.length; j++) {
                var existingGame = collections[i].games[j];
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
                var gameId = game.title;
                if (game.extra && game.extra.id) {
                    gameId = game.extra.id.toString();
                } else if (game.files && game.files.path) {
                    gameId = game.files.path;
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

function removeGameFromCollection(collectionId, gameTitle) {
    var collections = loadCustomCollections();

    for (var i = 0; i < collections.length; i++) {
        if (collections[i].id === collectionId) {
            var newGames = [];
            for (var j = 0; j < collections[i].games.length; j++) {
                if (collections[i].games[j].title !== gameTitle) {
                    newGames.push(collections[i].games[j]);
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

function isGameInCollection(collectionId, gameTitle) {
    var collections = loadCustomCollections();

    for (var i = 0; i < collections.length; i++) {
        if (collections[i].id === collectionId) {
            for (var j = 0; j < collections[i].games.length; j++) {
                if (collections[i].games[j].title === gameTitle) {
                    return true;
                }
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

    console.log("No se pudo encontrar el juego para lanzar:", gameTitle);
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
