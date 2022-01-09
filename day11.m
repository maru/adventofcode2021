#import "utils.h"

const int GRID_SIZE = 10;

@interface Position : NSObject {
    int row, col;
}
@property(nonatomic, readwrite) int row;
@property(nonatomic, readwrite) int col;

- (instancetype)initWithRow:(int)r col:(int)c;
@end

@implementation Position
@synthesize row;
@synthesize col;

- (instancetype)initWithRow:(int)r col:(int)c {
    self = [super init];
    if (self) {
        row = r;
        col = c;
    }
    return self;
}

@end

@interface Queue<ObjectType> : NSObject {
    NSMutableArray<ObjectType> *queue;
}

- (void)push:(ObjectType)v;
- (ObjectType)pop;
- (BOOL)is_empty;
@end

@implementation Queue
- (instancetype)init {
    self = [super init];
    if (self) {
        queue = [NSMutableArray array];
    }
    return self;
}
- (void)push:(id)anObject {
    [queue addObject:anObject];
}
- (id)pop {
    if ([self is_empty]) return nil;

    id o = [queue objectAtIndex:0];
    [queue removeObjectAtIndex:0];
    return o;
}
- (BOOL)is_empty {
    return [queue count] == 0;
}

@end

void print_grid(int octopus[GRID_SIZE][GRID_SIZE]) {
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            printf("%d", octopus[i][j]);
        }
        printf("\n");
    }
    printf("\n");
}

long doStep(int octopus[GRID_SIZE][GRID_SIZE]) {
    Queue *queue = [[Queue alloc] init];
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            octopus[i][j] = (octopus[i][j] + 1) % 10;
            if (octopus[i][j] == 0) {
                [queue push:[[Position alloc] initWithRow:i col:j]];
            }
        }
    }
    long flashes = 0;
    while (![queue is_empty]) {
        Position *pos = [queue pop];
        NSCAssert(pos.row >= 0 && pos.row < GRID_SIZE && pos.col >= 0 && pos.col < GRID_SIZE, @"out of bounds");
        flashes++;
        int offsets[8][2] = { {-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1} };
        for (int k = 0; k < 8; k++) {
            int row = pos.row + offsets[k][0];
            int col = pos.col + offsets[k][1];
            if (!(0 <= row && row < GRID_SIZE && 0 <= col && col < GRID_SIZE && octopus[row][col] > 0)) continue;
            octopus[row][col] = (octopus[row][col] + 1) % 10;
            if (octopus[row][col] == 0) {
                [queue push:[[Position alloc] initWithRow:row col:col]];
            }
        }
    }
    return flashes;
}

long doAllOctopusFlash(int octopus[GRID_SIZE][GRID_SIZE]) {
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            if (octopus[i][j] != 0) return NO;
        }
    }
    return YES;
}


int main(int argc, const char * argv[]) {
    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);

    int octopus[GRID_SIZE][GRID_SIZE] = {0};
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            octopus[i][j] = [[lines objectAtIndex:i] characterAtIndex:j] - '0';
        }
    }

    long flashes = 0;
    for (int step = 0; step < 100; step++) {
        flashes += doStep(octopus);
        NSCAssert(!doAllOctopusFlash(octopus), @"All octopus flashed!");
    }
    long all_flashes_step = 100;
    while (!doAllOctopusFlash(octopus)) {
        all_flashes_step++;
        doStep(octopus);
    }

    NSLog(@"(1) answer: %ld", flashes);
    NSLog(@"(2) answer: %ld", all_flashes_step);
    return 0;
}
