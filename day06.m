#import "utils.h"

const int MAX_SIZE = 9;

long getNumFishes(long fishes[MAX_SIZE], int num_days) {
    for (int d = 0; d < num_days; d++) {
        long new_fish = fishes[0];
        for (int i = 1; i < MAX_SIZE; i++) {
            fishes[i-1] = fishes[i];
        }
        fishes[6] += new_fish;
        fishes[8] = new_fish;
    }

    long num_fishes = 0;
    for (int i = 0; i < MAX_SIZE; i++) {
        num_fishes += fishes[i];
    }
    return num_fishes;
}

int main(int argc, const char * argv[]) {
    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);
    NSMutableCharacterSet *skipChars = [NSMutableCharacterSet characterSetWithCharactersInString:@","];

    NSScanner *scanner = [[NSScanner alloc] initWithString:lines[0]];
    [scanner setCharactersToBeSkipped:skipChars];
    NSInteger day;

    long fishes[MAX_SIZE] = {0};
    while ([scanner scanInteger:&day]) {
        fishes[day]++;
    }

    NSLog(@"(1) answer: %ld", getNumFishes(fishes, 80));
    NSLog(@"(2) answer: %ld", getNumFishes(fishes, 256-80));

    return 0;
}
