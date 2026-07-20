class Quads:
    def __init__(self, quad_size):
        self.quad_size = quad_size
        self.reset()

    def reset(self):
        self.objects = {}
        self.map = {}
        self.next_id = 0

    def add(self, obj, quad_loc):
        self.objects[self.next_id] = obj
        if quad_loc not in self.map:
            self.map[quad_loc] = []
        self.map[quad_loc].append(self.next_id)
        self.next_id += 1

    def add_raw(self, obj, rect):
        quad_locs = [
            (rect.x // self.quad_size, rect.y // self.quad_size),
            (rect.x + rect.width // self.quad_size, rect.y // self.quad_size),
            ((rect.x + rect.width) // self.quad_size, (rect.y + rect.height) // self.quad_size),
            (rect.x // self.quad_size, (rect.y + rect.height) // self.quad_size),
        ]
        quad_locs = set(quad_locs)
        for loc in quad_locs:
            self.add(obj, loc)

    def query(self, rect):
        # get bounding coords
        tl = (rect.x // self.quad_size, rect.y // self.quad_size)
        br = ((rect.x + rect.width) // self.quad_size, (rect.y + rect.height) // self.quad_size)

        # lookup entries
        results = []
        for x in range(br[0] - tl[0] + 1):
            for y in range(br[1] - tl[1] + 1):
                loc = (tl[0] + x, tl[1] + y)
                if loc in self.map:
                    results += self.map[loc]

        # remove duplicates
        results = set(results)

        return [self.objects[obj_id] for obj_id in results]
