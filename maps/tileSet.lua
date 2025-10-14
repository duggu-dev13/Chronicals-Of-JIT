return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 14,
  height = 11,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 13,
  nextobjectid = 132,
  properties = {},
  tilesets = {
    {
      name = "tileSet",
      firstgid = 1,
      class = "",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 31,
      image = "Classroom.png",
      imagewidth = 1000,
      imageheight = 1000,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      wangsets = {},
      tilecount = 961,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 14,
      height = 11,
      id = 1,
      name = "Base Floor",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        202, 202, 202, 202, 202, 202, 202, 202, 202, 202, 202, 202, 202, 202,
        409, 410, 409, 410, 409, 410, 409, 410, 409, 410, 325, 410, 409, 410,
        378, 379, 378, 379, 378, 379, 378, 379, 378, 379, 356, 379, 378, 379,
        409, 410, 409, 410, 409, 410, 409, 410, 409, 410, 356, 410, 409, 410,
        378, 379, 378, 379, 378, 379, 378, 379, 378, 379, 356, 379, 378, 379,
        409, 410, 409, 410, 409, 410, 409, 410, 409, 410, 356, 410, 409, 410,
        378, 379, 378, 379, 378, 379, 378, 379, 378, 379, 387, 379, 378, 379,
        409, 410, 409, 410, 409, 410, 409, 410, 409, 410, 409, 410, 409, 410
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 14,
      height = 11,
      id = 2,
      name = "Base Stage Floor",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 342, 343, 344, 343,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 373, 374, 375, 374,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 373, 405, 406, 405,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 404, 374, 375, 374,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 373, 374, 375, 374,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 435, 436, 437, 436,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 14,
      height = 11,
      id = 4,
      name = "Floor and Wall Objects",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 130,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 161,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 161,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 192,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 14,
      height = 11,
      id = 3,
      name = "Base Wall",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        256, 256, 256, 255, 256, 255, 256, 256, 255, 256, 255, 255, 255, 255,
        256, 255, 255, 255, 255, 256, 255, 255, 256, 255, 255, 256, 256, 255,
        287, 286, 287, 287, 286, 286, 286, 286, 286, 287, 287, 287, 286, 287,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 14,
      height = 11,
      id = 8,
      name = "Windows",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 63, 64, 65, 66, 0, 0, 0, 0, 63, 64, 65, 66, 0,
        0, 94, 95, 96, 97, 0, 0, 0, 0, 94, 95, 96, 97, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 14,
      height = 11,
      id = 5,
      name = "Wall Objects",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 9, 10, 11, 12, 0, 0, 0, 0, 75,
        0, 0, 0, 0, 76, 77, 78, 79, 74, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 107, 108, 109, 110, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 102, 102, 102, 102, 102, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 102, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 12,
      name = "Benches and Vegetation",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["depthMask "] = "True"
      },
      objects = {
        {
          id = 87,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 128,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 38,
          visible = true,
          properties = {
            ["benchId"] = "1",
            ["depthMask"] = "true"
          }
        },
        {
          id = 88,
          name = "",
          type = "",
          shape = "rectangle",
          x = 416,
          y = 352,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 38,
          visible = true,
          properties = {
            ["benchId"] = "4",
            ["depthMask"] = "true"
          }
        },
        {
          id = 89,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 352,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 7,
          visible = true,
          properties = {
            ["benchId"] = "3",
            ["depthMask"] = "true"
          }
        },
        {
          id = 90,
          name = "",
          type = "",
          shape = "rectangle",
          x = 352,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 7,
          visible = true,
          properties = {
            ["benchId"] = "5",
            ["depthMask"] = "true"
          }
        },
        {
          id = 91,
          name = "",
          type = "",
          shape = "rectangle",
          x = 352,
          y = 160,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {
            ["benchId"] = "6",
            ["depthMask"] = "true"
          }
        },
        {
          id = 92,
          name = "",
          type = "",
          shape = "rectangle",
          x = 416,
          y = 128,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 39,
          visible = true,
          properties = {
            ["benchId"] = "2",
            ["depthMask"] = "true"
          }
        },
        {
          id = 93,
          name = "",
          type = "",
          shape = "rectangle",
          x = 352,
          y = 192,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {
            ["benchId"] = "7",
            ["depthMask"] = "true"
          }
        },
        {
          id = 94,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 160,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "8",
            ["depthMask"] = "true"
          }
        },
        {
          id = 95,
          name = "",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 160,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "9",
            ["depthMask"] = "true"
          }
        },
        {
          id = 96,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160,
          y = 160,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "10",
            ["depthMask"] = "true"
          }
        },
        {
          id = 97,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224,
          y = 160,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "11",
            ["depthMask"] = "true"
          }
        },
        {
          id = 98,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224,
          y = 224,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "15",
            ["depthMask"] = "true"
          }
        },
        {
          id = 99,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160,
          y = 224,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "14",
            ["depthMask"] = "true"
          }
        },
        {
          id = 100,
          name = "",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 224,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "13",
            ["depthMask"] = "true"
          }
        },
        {
          id = 101,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 224,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "12",
            ["depthMask"] = "true"
          }
        },
        {
          id = 102,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "16",
            ["depthMask"] = "true"
          }
        },
        {
          id = 103,
          name = "",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "17",
            ["depthMask"] = "true"
          }
        },
        {
          id = 104,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "18",
            ["depthMask"] = "true"
          }
        },
        {
          id = 105,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 72,
          visible = true,
          properties = {
            ["benchId"] = "19",
            ["depthMask"] = "true"
          }
        },
        {
          id = 106,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 192,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "8",
            ["depthMask"] = "true"
          }
        },
        {
          id = 107,
          name = "",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 192,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "9",
            ["depthMask"] = "true"
          }
        },
        {
          id = 108,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160,
          y = 192,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "10",
            ["depthMask"] = "true"
          }
        },
        {
          id = 109,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224,
          y = 192,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "11",
            ["depthMask"] = "true"
          }
        },
        {
          id = 110,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224,
          y = 256,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "15",
            ["depthMask"] = "true"
          }
        },
        {
          id = 111,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160,
          y = 256,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "14",
            ["depthMask"] = "true"
          }
        },
        {
          id = 112,
          name = "",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 256,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "13",
            ["depthMask"] = "true"
          }
        },
        {
          id = 114,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 256,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "12",
            ["depthMask"] = "true"
          }
        },
        {
          id = 115,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 320,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "16",
            ["depthMask"] = "true"
          }
        },
        {
          id = 116,
          name = "",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 320,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "17",
            ["depthMask"] = "true"
          }
        },
        {
          id = 117,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160,
          y = 320,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "18",
            ["depthMask"] = "true"
          }
        },
        {
          id = 118,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224,
          y = 320,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 103,
          visible = true,
          properties = {
            ["benchId"] = "19",
            ["depthMask"] = "true"
          }
        },
        {
          id = 119,
          name = "",
          type = "",
          shape = "rectangle",
          x = 232,
          y = 283,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 120,
          name = "",
          type = "",
          shape = "rectangle",
          x = 258,
          y = 308,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 121,
          name = "",
          type = "",
          shape = "rectangle",
          x = 238,
          y = 330,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 122,
          name = "",
          type = "",
          shape = "rectangle",
          x = 189,
          y = 368,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 123,
          name = "",
          type = "",
          shape = "rectangle",
          x = 92,
          y = 410,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 124,
          name = "",
          type = "",
          shape = "rectangle",
          x = 127,
          y = -37,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 125,
          name = "",
          type = "",
          shape = "rectangle",
          x = 260,
          y = 158,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 126,
          name = "",
          type = "",
          shape = "rectangle",
          x = 263,
          y = 190,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 127,
          name = "",
          type = "",
          shape = "rectangle",
          x = 306,
          y = 132,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 128,
          name = "",
          type = "",
          shape = "rectangle",
          x = 477,
          y = 45,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 129,
          name = "",
          type = "",
          shape = "rectangle",
          x = 468,
          y = -1,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 130,
          name = "",
          type = "",
          shape = "rectangle",
          x = 263,
          y = 148,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        },
        {
          id = 131,
          name = "",
          type = "",
          shape = "rectangle",
          x = 299,
          y = 121,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 102,
          visible = true,
          properties = {
            ["depthMask"] = "true"
          }
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 9,
      name = "Walls",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 3,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 0,
          width = 447,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 46,
          name = "",
          type = "",
          shape = "rectangle",
          x = 34,
          y = 152,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 47,
          name = "",
          type = "",
          shape = "rectangle",
          x = 8,
          y = 115,
          width = 14,
          height = 11,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 48,
          name = "",
          type = "",
          shape = "rectangle",
          x = 34,
          y = 216,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 49,
          name = "",
          type = "",
          shape = "rectangle",
          x = 34,
          y = 280,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 50,
          name = "",
          type = "",
          shape = "rectangle",
          x = 98,
          y = 152,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 51,
          name = "",
          type = "",
          shape = "rectangle",
          x = 98,
          y = 216,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 52,
          name = "",
          type = "",
          shape = "rectangle",
          x = 98,
          y = 280,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 53,
          name = "",
          type = "",
          shape = "rectangle",
          x = 162,
          y = 152,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 54,
          name = "",
          type = "",
          shape = "rectangle",
          x = 162,
          y = 216,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 55,
          name = "",
          type = "",
          shape = "rectangle",
          x = 162,
          y = 280,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 56,
          name = "",
          type = "",
          shape = "rectangle",
          x = 226,
          y = 152,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 57,
          name = "",
          type = "",
          shape = "rectangle",
          x = 226,
          y = 216,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 58,
          name = "",
          type = "",
          shape = "rectangle",
          x = 226,
          y = 280,
          width = 26,
          height = 27,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 59,
          name = "",
          type = "",
          shape = "rectangle",
          x = 336,
          y = 155,
          width = 111,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 60,
          name = "",
          type = "",
          shape = "rectangle",
          x = 424,
          y = 115,
          width = 14,
          height = 11,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 62,
          name = "",
          type = "",
          shape = "rectangle",
          x = 8,
          y = 338,
          width = 14,
          height = 11,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 64,
          name = "",
          type = "",
          shape = "rectangle",
          x = 424,
          y = 339,
          width = 14,
          height = 10,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
