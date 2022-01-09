#import "utils.h"

const NSUInteger MAX_SIZE = 2000;

unsigned char hex(unsigned char c) {
    if ('0' <= c && c <= '9') {
        return c - '0';
    }
    return c - 'A' + 10;
}

@interface PacketReader: NSObject {
    unsigned char *buffer;
    size_t len;
    size_t offset;
    unsigned char mask;
    unsigned int nbit;
}

- (instancetype)initWithBuffer:(const char *)input len:(size_t)input_size;
- (unsigned int)get:(size_t)bits;
- (size_t)bits_left;
- (size_t)bits_read;
- (BOOL)is_end;
@end

@implementation PacketReader


- (instancetype)initWithBuffer:(const char *)input len:(size_t)input_size {
    self = [super init];
    if (self) {
        len = input_size/2;
        buffer = (unsigned char *)malloc(len);
        for (int i = 0; i < len; i++) {
            buffer[i] = (hex(input[2*i]) << 4) + hex(input[2*i + 1]);
        }
        offset = 0;
        mask = 0x80;
        nbit = 7;
    }
    return self;
}


- (unsigned int)get:(size_t)bits {
//    printf("[GET:%lu/%lu] ", bits, [self bits_left]);
    unsigned int n = 0;
    for (size_t i = 0; i < bits; i++) {
        NSCAssert(!self.is_end, @"no more bits");
        unsigned char b = ((buffer[offset/8] & mask) >> nbit);
        n = (n << 1) | b;
        offset++;
        mask = (mask == 1) ? 0x80 : (mask >> 1);
        nbit = nbit ? nbit - 1 : 7;
    }
    return n;
}

- (size_t)bits_left {
    return len*8 - offset;
}

- (size_t)bits_read {
    return offset;
}

- (BOOL)is_end {
    return offset == len*8;
}

- (long)getLiteralValue {
    long n = 0;
    size_t bits = 0;
    while (!self.is_end) {
        long b = [self get:5];
        n = (n << 4) | (b & 0x0F);
        bits += 5;
        if ((b & 0x10) == 0) {
            if (![self is_end] && [self bits_left] < 4)
                [self get:(bits % 4)];
            break;
        }
    }
    return n;
}

@end


long parsePacket(PacketReader *reader, long *sum_versions, int tab) {
//    printf("%*s", tab, " ");
    long version = [reader get:3];
//    printf("version: %lX ", version);
    long type_id = [reader get:3];
//    printf("type_id: %lX ", type_id);
    *sum_versions += version;

    long n = 0;
    if (type_id == 4) {
        n = [reader getLiteralValue];
//        printf("n: %ld\n", n);
        return n;
    }

    char op = ' ';
    switch (type_id) {
        case 0: op = '+'; break;
        case 1: op = '*'; break;
        case 2: op = 'm'; break;
        case 3: op = 'M'; break;
        case 5: op = '>'; break;
        case 6: op = '<'; break;
        case 7: op = '='; break;
    }
//    printf("op: %c ", op);

    unsigned char len_type_id = [reader get:1];
    if (len_type_id == 0) {
        long subpackets_len = [reader get:15];
//        printf("subpackets_len: %ld \n", subpackets_len);
        if (type_id >= 5) {
            size_t bits_last = [reader bits_read];
            long n1 = parsePacket(reader, sum_versions, tab+1);
            subpackets_len -= [reader bits_read] - bits_last;
            bits_last = [reader bits_read];
            long n2 = parsePacket(reader, sum_versions, tab+1);
            subpackets_len -= [reader bits_read] - bits_last;
            NSCAssert(subpackets_len == 0, @"need 2 packets");
            if (type_id == 5) return n1 > n2;
            if (type_id == 6) return n1 < n2;
            if (type_id == 7) return n1 == n2;
        } else {
            size_t bits_last = [reader bits_read];
            n = parsePacket(reader, sum_versions, tab+1);
            subpackets_len -= [reader bits_read] - bits_last;
            bits_last = [reader bits_read];
            while (subpackets_len > 0) {
                long v = parsePacket(reader, sum_versions, tab+1);
                subpackets_len -= [reader bits_read] - bits_last;
                bits_last = [reader bits_read];
                if (type_id == 0) n += v;
                else if (type_id == 1) n *= v;
                else if (type_id == 2) n = MIN(n, v);
                else if (type_id == 3) n = MAX(n, v);
            }
        }
    } else {
        long subpackets_num = [reader get:11];
//        printf("subpackets_num: %ld \n", subpackets_num);
        if (type_id >= 5) {
            NSCAssert(subpackets_num == 2, @"need 2 packets");
            long n1 = parsePacket(reader, sum_versions, tab+1);
            long n2 = parsePacket(reader, sum_versions, tab+1);
            if (type_id == 5) return n1 > n2;
            if (type_id == 6) return n1 < n2;
            if (type_id == 7) return n1 == n2;
        } else {
            n = parsePacket(reader, sum_versions, tab+1);
            for (int i = 1; i < subpackets_num; i++) {
                long v = parsePacket(reader, sum_versions, tab+1);
                if (type_id == 0) n += v;
                else if (type_id == 1) n *= v;
                else if (type_id == 2) n = MIN(n, v);
                else if (type_id == 3) n = MAX(n, v);
            }
        }
    }
    return n;
}

int main(int argc, const char * argv[]) {
    NSString *input = readInputFromStdin();
    NSArray<NSString *> *lines = parseLines(input);
    PacketReader *reader = [[PacketReader alloc] initWithBuffer:[lines[0] UTF8String] len:[lines[0] length]];
    long sum_versions = 0;
    long n = parsePacket(reader, &sum_versions, 0);
    NSLog(@"(1) answer: %ld", sum_versions);
    NSLog(@"(2) answer: %ld", n);
    return 0;
}
