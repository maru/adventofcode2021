#import "utils.h"

int MAX_BOARD_SIZE = 5;

typedef NS_ENUM(NSUInteger, WinPositionType) {
    kWinPositionFirst,
    kWinPositionLast,
};

@interface BoardNumber : NSObject {
    int _row, _col;
}
@property(nonatomic, readwrite) int row;
@property(nonatomic, readwrite) int col;

- (instancetype)initWithRow:(int)r col:(int)c;
@end

@implementation BoardNumber

- (instancetype)initWithRow:(int)r col:(int)c {
    self = [super init];
    if (self) {
        _row = r;
        _col = c;
    }
    return self;
}

@end

@interface Board : NSObject {
    NSMutableDictionary *numbers;
    NSInteger _sumUnmarked;
    NSMutableArray *rows, *cols;
    BOOL _winner;
    int boardSize;
}
@property(nonatomic, readwrite) NSInteger sumUnmarked;
@property(nonatomic, readonly, getter=isWinner) BOOL winner;

- (void)addNumber:(NSInteger)number position:(BoardNumber*)position;
- (BOOL)markNumber:(NSInteger)number;
- (BOOL)isWinner;
- (void)print;

@end

@implementation Board

- (instancetype)init {
    self = [super init];
    if (self) {
        numbers = [NSMutableDictionary dictionary];
        _sumUnmarked = 0;
        _winner = NO;
        rows = [NSMutableArray array];
        cols = [NSMutableArray array];
        boardSize = MAX_BOARD_SIZE;
        for (int i = 0; i < boardSize; i++) {
            [rows addObject:@(boardSize)];
            [cols addObject:@(boardSize)];
        }
    }
    return self;
}

- (void)print {
    for (NSNumber *key in numbers) {
        BoardNumber*position = numbers[key];
        NSLog(@"%d = (%d, %d)", (int)[key integerValue], position.row, position.col);
    }
}

- (void)addNumber:(NSInteger)number position:(BoardNumber*)position {
    [numbers setObject:position forKey:@(number)];
}

- (BOOL)markNumber: (NSInteger)number {
    BoardNumber *position = [numbers objectForKey:@(number)];
    if (position == NULL) return NO;

    // Assuming numbers are unique, so not marking them as 'visited'
    _sumUnmarked -= number;
    rows[position.row] = @([rows[position.row] integerValue] - 1);
    cols[position.col] = @([cols[position.col] integerValue] - 1);
    _winner = ([rows[position.row] integerValue] == 0 || [cols[position.col] integerValue] == 0);
    return YES;
}

@end



NSInteger playBingo(NSArray<NSString *> *lines, WinPositionType winPosition) {
    NSInteger num_lines = [lines count];
    NSMutableArray *boards = [NSMutableArray array];
    // parseLines skips blank lines, so start from lines[1]
    for (int first = 1; first < num_lines; first += MAX_BOARD_SIZE) {
        Board *board = [[Board alloc] init];
        NSInteger number;
        for (int i = first; i < first + MAX_BOARD_SIZE; i++) {
            int row = i - first;
            NSScanner *scanner = [[NSScanner alloc] initWithString:lines[i]];
            int col = 0;
            while ([scanner scanInteger:&number]) {
                board.sumUnmarked += number;
                BoardNumber *pos = [[BoardNumber alloc] initWithRow:row col:col++];
                [board addNumber:number position:pos];
            }
        }
        [boards addObject:board];
    }

    // Draw numbers
    NSScanner *scanner = [[NSScanner alloc] initWithString:lines[0]];
    [scanner setCharactersToBeSkipped:[NSCharacterSet punctuationCharacterSet]];
    NSInteger numWinner = 0, number;
    while ([scanner scanInteger:&number]) {
        for (int i = 0; i < [boards count]; i++) {
            Board *board = boards[i];
            if ([board isWinner]) continue;
            if (![board markNumber:number]) continue;
            if (![board isWinner]) continue;
            NSInteger score = board.sumUnmarked*number;
            numWinner++;
            if ((winPosition == kWinPositionFirst && numWinner == 1) ||
                (winPosition == kWinPositionLast && numWinner == [boards count])){
                return score;
            }
        }
    }
    return 0;
}

int main(int argc, const char * argv[]) {
    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);

    NSLog(@"(1) answer: %ld", (long) playBingo(lines, kWinPositionFirst));
    NSLog(@"(2) answer: %ld", (long) playBingo(lines, kWinPositionLast));
    return 0;
}
