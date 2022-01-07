#import "utils.h"

const int MAX_SIZE = 2000;

void parseFoldAction(NSString *line, char *direction, int *num_line) {
    *direction = [line characterAtIndex:0];
    for (int i = 2; i < [line length]; i++) {
        *num_line = *num_line*10 + [line characterAtIndex:i] - '0';
    }
}

void print(char paper[MAX_SIZE][MAX_SIZE], int max_x, int max_y) {
    for (int j = 0; j <= max_y; j++) {
        for (int i = 0; i <= max_x; i++) {
            if (!paper[i][j]) paper[i][j] = '.';
            printf("%c", paper[i][j]);
        }
        printf("\n");
    }
    printf("\n");
}

long countPoints(char paper[MAX_SIZE][MAX_SIZE], int max_x, int max_y) {
    long c = 0;
    for (int i = 0; i <= max_x; i++) {
        for (int j = 0; j <= max_y; j++) {
            c += (paper[i][j] == '#');
        }
    }
    return c;
}

void fold(char paper[MAX_SIZE][MAX_SIZE], char direction, int num_line, int *max_x, int *max_y) {
    if (direction == 'x') {
        for (int i = 0, k = num_line*2; i < num_line; i++, k--) {
            for (int j = 0; j <= *max_y; j++) {
                paper[i][j] = (paper[i][j] == '#' || paper[k][j] == '#') ? '#' : '.';
            }
        }
        *max_x = num_line - 1;
    } else {
        for (int j = 0, k = num_line*2; j < num_line; j++, k--) {
            for (int i = 0; i <= *max_x; i++) {
                paper[i][j] = (paper[i][j] == '#' || paper[i][k] == '#') ? '#' : '.';
            }
        }
        *max_y = num_line - 1;
    }
}

int main(int argc, const char * argv[]) {
    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);

    char paper[MAX_SIZE][MAX_SIZE] = {0};
    int max_x = 0, max_y = 0;
    long count_1fold = 0;
    for (NSString *line in lines) {
        if ([line characterAtIndex:0] == 'f') {
            NSArray *tokens = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            char direction;
            int num_line = 0;
            parseFoldAction(tokens[2], &direction, &num_line);
//            print(paper, max_x, max_y);
            fold(paper, direction, num_line, &max_x, &max_y);
            if (count_1fold == 0) {
                count_1fold = countPoints(paper, max_x, max_y);
                NSLog(@"(1) answer: %ld", count_1fold);
            }
        } else {
            NSArray *tokens = [line componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
            int x = (int) [tokens[0] integerValue];
            int y = (int) [tokens[1] integerValue];
            max_x = MAX(max_x, x);
            max_y = MAX(max_y, y);
            paper[x][y] = '#';
        }
    }
    NSLog(@"(2) answer:");
    print(paper, max_x, max_y);
    return 0;
}
