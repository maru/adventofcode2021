#import "utils.h"

NSString* readInputFromStdin(void)
{
    NSFileHandle *fp = [NSFileHandle fileHandleWithStandardInput];
    NSData *inputData = [NSData dataWithData:[fp readDataToEndOfFile]];
    NSString *input = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
    return input;
}

NSArray* parseLines(NSString *input) {
    NSMutableArray* lines = [[input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    [lines removeObject:@""];
    return lines;
}
