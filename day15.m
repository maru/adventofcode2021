#import "utils.h"

const NSUInteger MAX_SIZE = 500;

@interface Position : NSObject {
    int row, col;
    NSUInteger risk;
}
@property(nonatomic, readwrite) NSUInteger risk;
@property(nonatomic, readwrite) int row;
@property(nonatomic, readwrite) int col;

- (instancetype)initWithRow:(int)r col:(int)c risk:(NSUInteger)rk;
@end

@implementation Position
@synthesize risk;
@synthesize row;
@synthesize col;

- (instancetype)initWithRow:(int)r col:(int)c risk:(NSUInteger)rk {
    self = [super init];
    if (self) {
        row = r;
        col = c;
        risk = rk;
    }
    return self;
}

@end

@interface PriorityQueue : NSObject {
    CFBinaryHeapRef _heap;
    NSUInteger _count;
}

- (instancetype)init;
- (void)push:(Position *)anObject;
- (Position *)get_min;
- (NSUInteger)count;

@end

@implementation PriorityQueue
static const void *_retain(CFAllocatorRef allocator, const void *ptr)
{
    return CFRetain(ptr);
}

static void _release(CFAllocatorRef allocator, const void *ptr)
{
    CFRelease(ptr);
}

static CFComparisonResult _compare(const void *ptr1, const void *ptr2, void *context)
{
    Position *a = (__bridge Position *)ptr1;
    Position *b = (__bridge Position *)ptr2;

    return (CFComparisonResult)(b.risk < a.risk);
}

- (instancetype)init {
    if ((self = [super init])) {
        CFBinaryHeapCallBacks callbacks;
        callbacks.version = 0;

        callbacks.retain = _retain;
        callbacks.release = _release;
        callbacks.copyDescription = NULL;
        callbacks.compare = _compare;

        _heap = CFBinaryHeapCreate(kCFAllocatorDefault, 0, &callbacks, NULL);
        _count = 0;
    }
    return self;
}

- (void)push:(Position *)anObject {
    CFBinaryHeapAddValue(_heap, (__bridge void *)anObject);
    _count++;
}
- (Position *)get_min {
    Position *next = (Position *)CFBinaryHeapGetMinimum(_heap);
    if (next == nil) {
        // priority queue is empty
        return nil;
    }
    _count--;
    CFBinaryHeapRemoveMinimumValue(_heap);
    return next;
}
- (NSUInteger)count {
    return _count;
}

@end

long findShortestPath(NSUInteger cave[MAX_SIZE][MAX_SIZE], NSUInteger risk[MAX_SIZE][MAX_SIZE], Position *start, Position *end, NSUInteger h, NSUInteger w) {
    memset(risk, -1, MAX_SIZE*MAX_SIZE*sizeof(NSUInteger));

    PriorityQueue *queue = [PriorityQueue new];
    [queue push:start];

    while ([queue count] > 0) {
        Position *p = [queue get_min];
        if (risk[p.row][p.col] <= p.risk) continue;
        risk[p.row][p.col] = p.risk;
        int offsets[4][2] = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};
        for (int k = 0; k < 4; k++) {
            int r = p.row + offsets[k][0];
            int c = p.col + offsets[k][1];
            if (!(0 <= r && r < h && 0 <= c && c < w)) continue;
            if (risk[r][c] <= p.risk + cave[r][c]) continue;
            [queue push:[[Position alloc] initWithRow:r col:c risk:(p.risk + cave[r][c])]];
        }
    }
    return risk[h-1][w-1];
}

int main(int argc, const char * argv[]) {
    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);

    NSUInteger h = lines.count, w = lines[0].length;
    NSUInteger cave[MAX_SIZE][MAX_SIZE], risk[MAX_SIZE][MAX_SIZE];
    for (NSUInteger i = 0; i < h; i++) {
        for (NSUInteger j = 0; j < w; j++) {
            cave[i][j] = [lines[i] characterAtIndex:j] - '0';
            risk[i][j] = 20000;
        }
    }
    Position *start = [[Position alloc] initWithRow:0 col:0 risk:0];
    Position *end = [[Position alloc] initWithRow:(int)h-1 col:(int)w-1 risk:0];
    NSLog(@"(1) answer: %ld", findShortestPath(cave, risk, start, end, h, w));

    // 5x larger
    for (NSUInteger i = 0; i < h; i++) {
        for (NSUInteger j = w; j < 5*w; j++) {
            cave[i][j] = cave[i][j-w] == 9 ? 1 : cave[i][j-w] + 1;
        }
    }
    for (NSUInteger i = h; i < 5*h; i++) {
        for (NSUInteger j = 0; j < 5*w; j++) {
            cave[i][j] = cave[i-h][j] == 9 ? 1 : cave[i-h][j] + 1;
        }
    }
    NSLog(@"(2) answer: %ld", findShortestPath(cave, risk, start, end, 5*h, 5*w));
    return 0;
}
