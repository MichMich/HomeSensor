//
//  TableViewController.m
//  HomeSensor
//
//  Created by Michael Teeuw on 25-04-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@property (strong, nonatomic) NSArray *events;

@end

@implementation TableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.title = @"Home Sensor";
    
    [self getEvents];
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(getEvents) forControlEvents:UIControlEventValueChanged];

    self.refreshControl = refresh;
    
}


- (void)getEvents
{
    NSLog(@"Get Events");
    
    
    [self performRequestWithUri:@"/" params:nil completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            self.events = (NSArray *)response;
            
            [self.tableView reloadData];
        }
    }];
    
    [self.refreshControl endRefreshing];
}




- (void)performRequestWithUri:(NSString *)requestUri params:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    
    // Generate the URL
    NSString *requestUrl = [NSString stringWithFormat:@"http://192.168.0.123:8081%@", requestUri];
    
    // Create the connection
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    
    // Make an NSOperationQueue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setName:@"nl.xonaymedia.homesensor.api"];
    
    // Send an asyncronous request on the queue
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // If there was an error getting the data
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                completionBlock(nil, error);
            });
            return;
        }
        
        // Decode the data
        NSError *jsonError;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        // If there was an error decoding the JSON
        if (jsonError) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
            });
            return;
        }
        
        // All looks fine, lets call the completion block with the response data
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completionBlock(responseDict, nil);
        });
    }];
}





#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.events count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    
    NSDictionary *event = self.events[indexPath.row];
    
    NSString *description = [event valueForKeyPath:@"description"];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[[event valueForKey:@"timestamp"] intValue]];
    
    cell.textLabel.text= description;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", timestamp];
    
    return cell;
}


@end
