#import <Foundation/Foundation.h>
#import "utils.h"

const int MAX_SIZE = 30;
typedef enum {
    kVisitMaxOne = 1,
    kVisitMaxTwice = 2
} NumberMaxVisitType;

int getNodeId(NSDictionary *node_to_id, id key) {
    return (int) [[node_to_id objectForKey:key] integerValue];
}

long countAllPaths(int node_id, int adj_matrix[MAX_SIZE][MAX_SIZE], int visited[MAX_SIZE], NSDictionary *node_to_id, bool small_cave[MAX_SIZE], NumberMaxVisitType max_visit, bool did_visit_twice) {
    if (node_id == getNodeId(node_to_id, @"end")) {
        return 1;
    }
    long count = 0;
    for (int i = 0; i < MAX_SIZE; i++) {
        if (adj_matrix[node_id][i] == 0) continue;
        if (small_cave[i]) {
            if (max_visit == kVisitMaxOne) {
                if (visited[i] == 1) continue;
            } else { // max_visit == kVisitMaxTwice
                if (visited[i] == 1 &&
                    (i == getNodeId(node_to_id, @"end") || i == getNodeId(node_to_id, @"start"))) continue;
                if ((visited[i] == 2)|| (visited[i] == 1 && did_visit_twice)) continue;
            }
        }
        
        visited[i]++;
        if (small_cave[i] && visited[i] == 2) did_visit_twice = true;
        count += countAllPaths(i, adj_matrix, visited, node_to_id, small_cave, max_visit, did_visit_twice);
        if (small_cave[i] && visited[i] == 2) did_visit_twice = false;
        visited[i]--;
    }
    return count;
}

int main(int argc, const char * argv[]) {
    NSString *input = getInputFromStdin();
    NSArray<NSString *> *lines = getLines(input);

    int node_id = 0;
    NSMutableDictionary *node_to_id = [NSMutableDictionary dictionary];
    int adj_matrix[MAX_SIZE][MAX_SIZE] = {0};
    bool small_cave[MAX_SIZE] = {0};
    for (NSString *line in lines) {
        NSArray *nodes = [line componentsSeparatedByCharactersInSet:[NSMutableCharacterSet characterSetWithCharactersInString:@"-"]];

        if ([node_to_id objectForKey:nodes[0]] == nil) {
            [node_to_id setObject:@(node_id) forKey:nodes[0]];
            small_cave[node_id] = [nodes[0] isEqualTo:[nodes[0] lowercaseString]];
            node_id++;
        }
        if ([node_to_id objectForKey:nodes[1]] == nil) {
            [node_to_id setObject:@(node_id) forKey:nodes[1]];
            small_cave[node_id] = [nodes[1] isEqualTo:[nodes[1] lowercaseString]];
            node_id++;
        }
        int id0 = getNodeId(node_to_id, nodes[0]);
        int id1 = getNodeId(node_to_id, nodes[1]);
        adj_matrix[id0][id1] = adj_matrix[id1][id0] = 1;

    }

    int visited[MAX_SIZE] = {0};
    visited[getNodeId(node_to_id, @"start")]++;
    long all_paths_max_1 = countAllPaths(getNodeId(node_to_id, @"start"), adj_matrix, visited, node_to_id, small_cave, kVisitMaxOne, false);
    NSLog(@"(1) answer: %ld", all_paths_max_1);

    long all_paths_max_2 = countAllPaths(getNodeId(node_to_id, @"start"), adj_matrix, visited, node_to_id, small_cave, kVisitMaxTwice, false);
    NSLog(@"(2) answer: %ld", all_paths_max_2);
    return 0;
}
