#import <Foundation/Foundation.h>
#import "utils.h"

const NSUInteger MAX_SIZE_PAIRS = 1ULL << 16;
const NSUInteger MAX_SIZE_COUNT = 1ULL << 8;

NSUInteger getPair(char a, char b) {
    return (a << 8) | b;
}

void getElems(NSUInteger p, char *ch1, char *ch2) {
    *ch1 = (char)((p >> 8) & 0xFF);
    *ch2 = (char)(p & 0xFF);
}

void doStep(NSUInteger *pairs, NSUInteger *tmp, NSUInteger *count_c, NSDictionary *rules) {
    memset(tmp, '\0', MAX_SIZE_PAIRS*sizeof(NSUInteger));
    for (NSUInteger i = 0; i < MAX_SIZE_PAIRS; i++) {
        if (pairs[i] == 0) continue;
        char ch1, ch2;
        getElems(i, &ch1, &ch2);
        NSMutableString *key = [[NSMutableString alloc] initWithFormat:@"%c%c", ch1, ch2];
        char ch = [[rules objectForKey:key] characterAtIndex:0];
        tmp[getPair(ch1, ch)] += pairs[i];
        tmp[getPair(ch, ch2)] += pairs[i];
        count_c[ch] += pairs[i];
    }
    memcpy(pairs, tmp, MAX_SIZE_PAIRS*sizeof(NSUInteger));
}

NSUInteger getDiffMinMax(NSUInteger *count_c) {
    NSUInteger min_c = LONG_LONG_MAX, max_c = 0;
    for (char c = 'A'; c <= 'Z'; c++) {
        if (count_c[c] == 0) continue;
        min_c = MIN(min_c, count_c[c]);
        max_c = MAX(max_c, count_c[c]);
    }
    return max_c - min_c;
}

int main(int argc, const char * argv[]) {
    NSString *input = getInputFromStdin();
    NSArray<NSString *> *lines = getLines(input);
    
    NSMutableDictionary *rules = [NSMutableDictionary dictionary];
    NSMutableCharacterSet *skipChars = [NSMutableCharacterSet characterSetWithCharactersInString:@" "];
    for (int i = 1; i < lines.count; i++) {
        NSArray *tokens = [lines[i] componentsSeparatedByCharactersInSet:skipChars];
        [rules setObject:tokens[2] forKey:tokens[0]];
    }
    
    NSUInteger count_c[MAX_SIZE_COUNT];
    memset(count_c, '\0', MAX_SIZE_COUNT*sizeof(NSUInteger));
    int len = (int) lines[0].length;
    for (int i = 0; i < len; i++) {
        char c = [lines[0] characterAtIndex:i];
        count_c[c]++;
    }
    
    // The order in which we process pairs is not relevant, so we can just save the number of each one.
    // This helps us to avoid working with the resulting string, making O(len string) >> 2**32 into O(pairs) < 2**16
    NSUInteger pairs[MAX_SIZE_PAIRS], tmp[MAX_SIZE_PAIRS];
    memset(pairs, '\0', MAX_SIZE_PAIRS*sizeof(NSUInteger));
    for (int i = 0; i < len-1; i++) {
        NSUInteger p = getPair([lines[0] characterAtIndex:i], [lines[0] characterAtIndex:i+1]);
        pairs[p]++;
    }
    
    for (int step = 0; step < 10; step++) {
        doStep(pairs, tmp, count_c, rules);
    }
    NSLog(@"(1) answer: %ld", getDiffMinMax(count_c));
    
    for (int step = 10; step < 40; step++) {
        doStep(pairs, tmp, count_c, rules);
    }
    NSLog(@"(2) answer: %ld", getDiffMinMax(count_c));
    return 0;
}
