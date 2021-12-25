#import <Foundation/Foundation.h>
#import "utils.h"

@interface Position : NSObject {
    int row, col;
}
@property(nonatomic, readwrite) int row;
@property(nonatomic, readwrite) int col;

-(id)initWithRowCol:(int)r andCol:(int)c;
@end

@implementation Position
@synthesize row;
@synthesize col;

-(id)initWithRowCol:(int)r andCol:(int)c {
    row = r;
    col = c;
    return self;
}

@end

int getValue(int cave[100][100], int i, int j, NSInteger cave_height, NSInteger cave_width) {
    if ((j < 0) || (i < 0) || (i >= cave_height) || (j >= cave_width)) return 1000;
    return cave[i][j];
}

bool isLowPoint(long h, int cave[100][100], int i, int j, NSInteger cave_height, NSInteger cave_width) {
    int a = getValue(cave, i, j-1, cave_height, cave_width);
    int b = getValue(cave, i-1, j, cave_height, cave_width);
    int c = getValue(cave, i, j+1, cave_height, cave_width);
    int d = getValue(cave, i+1, j, cave_height, cave_width);
    return (h < a && h < b && h < c && h < d);
}

void addValueIfValid(int cave[100][100], int val, int i, int j, NSInteger cave_height, NSInteger cave_width, NSMutableArray *queue, bool visited[100][100]) {
    int a = getValue(cave, i, j, cave_height, cave_width);
    if (a < 9 && val < a && !visited[i][j]) [queue addObject:[[Position alloc] initWithRowCol:i andCol:j]];
}

long findBasin(int cave[100][100], int i, int j, NSInteger cave_height, NSInteger cave_width) {
    long size_basin = 0;
    bool visited[100][100] = {0};

    NSMutableArray *queue = [[NSMutableArray alloc] init];
    [queue addObject:[[Position alloc] initWithRowCol:i andCol:j]];
    while ([queue count] > 0) {
        Position *pos = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        NSCAssert(pos.row >= 0 && pos.row < 100 && pos.col >= 0 && pos.col < 100, @"out of bounds");
        if (visited[pos.row][pos.col]) continue;
        visited[pos.row][pos.col] = true;
        size_basin++;

        addValueIfValid(cave, cave[pos.row][pos.col], pos.row, pos.col-1, cave_height, cave_width, queue, visited);
        addValueIfValid(cave, cave[pos.row][pos.col], pos.row-1, pos.col, cave_height, cave_width, queue, visited);
        addValueIfValid(cave, cave[pos.row][pos.col], pos.row, pos.col+1, cave_height, cave_width, queue, visited);
        addValueIfValid(cave, cave[pos.row][pos.col], pos.row+1, pos.col, cave_height, cave_width, queue, visited);
    }
    return size_basin;
}

int main(int argc, const char * argv[]) {
    NSString *input = getInputFromStdin();
    NSArray<NSString *> *lines = getLines(input);
    NSInteger cave_height = [lines count];
    NSInteger cave_width = lines[0].length;

    int cave[100][100] = {0};
    for (int i = 0; i < cave_height; i++) {
        for (int j = 0; j < cave_width; j++) {
            cave[i][j] = [[lines objectAtIndex:i] characterAtIndex:j] - '0';
        }
    }

    long sum_risk = 0;
    NSMutableArray *basins = [[NSMutableArray alloc] init];
    for (int i = 0; i < cave_height; i++) {
        for (int j = 0; j < cave_width; j++) {
            long h = cave[i][j];
            if (isLowPoint(h, cave, i, j, cave_height, cave_width)) {
                sum_risk += h + 1;
            } else {
                continue;
            }
            long size_basin = findBasin(cave, i, j, cave_height, cave_width);
            [basins addObject:@(size_basin)];
        }
    }
    
    NSArray *sorted = [basins sortedArrayUsingSelector: @selector(compare:)];
    long largest_basins = 1;
    for (long i = 0; i < 3; i++) {
        long idx = [sorted count] - 1 - i;
        NSCAssert(idx >= 0, @"out of bounds");
        largest_basins *= [[sorted objectAtIndex:idx] integerValue];
    }
    
    NSLog(@"(1) answer: %ld", sum_risk);
    NSLog(@"(2) answer: %ld", largest_basins);
    return 0;
}
