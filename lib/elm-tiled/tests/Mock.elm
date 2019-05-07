module Mock exposing (..)


bareMinimum : String
bareMinimum =
    """{ "height":2,
 "infinite":false,
 "layers":[
        {
         "data":"AAAAAAAAAAAAAAAAAAAAAA==",
         "encoding":"base64",
         "height":2,
         "name":"Tile Layer 1",
         "opacity":1,
         "type":"tilelayer",
         "visible":true,
         "width":2,
         "x":0,
         "y":0
        }],
 "nextobjectid":1,
 "orientation":"orthogonal",
 "properties":
    {
     "gravity":60
    },
 "propertytypes":
    {
     "gravity":"float"
    },
 "renderorder":"right-down",
 "tiledversion":"1.1.3",
 "tileheight":16,
 "tilesets":[],
 "tilewidth":16,
 "type":"map",
 "version":1,
 "width":2
}"""


tilesDataNewWithProps : String
tilesDataNewWithProps =
    """{"columns":4,"firstgid":1025,"image":"level2/char1_test.png","imageheight":120,"imagewidth":64,"margin":0,"name":"char","spacing":0,"tilecount":20,"tileheight":24,"tiles":[{"animation":[{"duration":100,"tileid":0}],"id":0,"objectgroup":{"draworder":"index","name":"","objects":[{"height":19,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":3,"y":5}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0},"properties":[{"name":"testFloatProp","type":"float","value":123}]},{"animation":[{"duration":100,"tileid":4},{"duration":100,"tileid":5},{"duration":100,"tileid":6},{"duration":100,"tileid":7}],"id":4,"objectgroup":{"draworder":"index","name":"","objects":[{"height":19,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":1,"y":5}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0},"properties":[{"name":"testIntProp","type":"int","value":12312}]},{"id":5,"objectgroup":{"draworder":"index","name":"","objects":[{"height":18,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":3,"y":6}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},{"id":6,"objectgroup":{"draworder":"index","name":"","objects":[{"height":17,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":4,"y":7}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},{"id":7,"objectgroup":{"draworder":"index","name":"","objects":[{"height":18,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":6,"y":6}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},{"animation":[{"duration":100,"tileid":8},{"duration":100,"tileid":9},{"duration":100,"tileid":10},{"duration":100,"tileid":11}],"id":8,"objectgroup":{"draworder":"index","name":"","objects":[{"height":5,"id":2,"name":"","rotation":0,"type":"","visible":true,"width":16,"x":0,"y":19}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},{"id":9,"objectgroup":{"draworder":"index","name":"","objects":[{"height":9,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":11,"x":3,"y":15}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},{"id":10,"objectgroup":{"draworder":"index","name":"","objects":[{"height":17,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":3,"y":7}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},{"id":11,"objectgroup":{"draworder":"index","name":"","objects":[{"height":19,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":4,"x":6,"y":5}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}}],"tilewidth":16,"transparentcolor":"#ff00ff"}"""


tilesDataOldWithProps : String
tilesDataOldWithProps =
    """{"columns":4,"firstgid":1025,"image":"level2/char1_test.png","imageheight":120,"imagewidth":64,"margin":0,"name":"char","spacing":0,"tilecount":20,"tileheight":24,"tileproperties":{"0":{"testFloatProp":123},"4":{"testIntProp":12312}},"tilepropertytypes":{"0":{"testFloatProp":"float"},"4":{"testIntProp":"int"}},"tiles":{"0":{"animation":[{"duration":100,"tileid":0}],"objectgroup":{"draworder":"index","name":"","objects":[{"height":19,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":3,"y":5}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},"4":{"animation":[{"duration":100,"tileid":4},{"duration":100,"tileid":5},{"duration":100,"tileid":6},{"duration":100,"tileid":7}],"objectgroup":{"draworder":"index","name":"","objects":[{"height":19,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":1,"y":5}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},"5":{"objectgroup":{"draworder":"index","name":"","objects":[{"height":18,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":3,"y":6}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},"6":{"objectgroup":{"draworder":"index","name":"","objects":[{"height":17,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":4,"y":7}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},"7":{"objectgroup":{"draworder":"index","name":"","objects":[{"height":18,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":6,"y":6}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},"8":{"animation":[{"duration":100,"tileid":8},{"duration":100,"tileid":9},{"duration":100,"tileid":10},{"duration":100,"tileid":11}],"objectgroup":{"draworder":"index","name":"","objects":[{"height":5,"id":2,"name":"","rotation":0,"type":"","visible":true,"width":16,"x":0,"y":19}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},"9":{"objectgroup":{"draworder":"index","name":"","objects":[{"height":9,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":11,"x":3,"y":15}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},"10":{"objectgroup":{"draworder":"index","name":"","objects":[{"height":17,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":10,"x":3,"y":7}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}},"11":{"objectgroup":{"draworder":"index","name":"","objects":[{"height":19,"id":1,"name":"","rotation":0,"type":"","visible":true,"width":4,"x":6,"y":5}],"opacity":1,"type":"objectgroup","visible":true,"x":0,"y":0}}},"tilewidth":16,"transparentcolor":"#ff00ff"}"""


tilesDataOldAnimations : String
tilesDataOldAnimations =
    """{"columns":4,"firstgid":1,"image":"level2/char1_test.png","imageheight":120,"imagewidth":64,"margin":0,"name":"char1_test","spacing":0,"tilecount":20,"tileheight":24,"tiles":{"4":{"animation":[{"duration":100,"tileid":4},{"duration":100,"tileid":5},{"duration":100,"tileid":6},{"duration":100,"tileid":7}]}},"tilewidth":16,"transparentcolor":"#ff00ff"}"""


tilesDataNewAnimations : String
tilesDataNewAnimations =
    """{"columns":4,"firstgid":1,"image":"level2/char1_test.png","imageheight":120,"imagewidth":64,"margin":0,"name":"char1_test","spacing":0,"tilecount":20,"tileheight":24,"tiles":[{"animation":[{"duration":100,"tileid":4},{"duration":100,"tileid":5},{"duration":100,"tileid":6},{"duration":100,"tileid":7}],"id":4}],"tilewidth":16,"transparentcolor":"#ff00ff"}"""
