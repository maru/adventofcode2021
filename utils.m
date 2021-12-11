#import <Foundation/Foundation.h>

NSString* getInputFromStdin(void)
{
    NSFileHandle *fp = [NSFileHandle fileHandleWithStandardInput];
    NSData *inputData = [NSData dataWithData:[fp readDataToEndOfFile]];
    NSString *input = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
    return input;
}
