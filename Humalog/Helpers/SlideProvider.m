//
//  ContentProvider.m
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "SlideProvider.h"
#import "WebContentView.h"

@interface SlideProvider() {
    NSMutableDictionary *documentAnnotations;
    NSArray             *documentTitles;
    NSArray             *categoriesAndIndices;
    WebContentView      *webContentView;
}

@end

@implementation SlideProvider
@synthesize delegate;

- (id)init
{
    if ((self = [super init])) {
        webContentView = [[WebContentView alloc] init];
        webContentView.delegate = self;
        webContentView.scalesPageToFit = NO;
        webContentView.scrollView.scrollEnabled = NO;
        
        documentAnnotations = [NSMutableDictionary dictionary];
                
        categoriesAndIndices = [NSArray arrayWithObjects:
                                [NSValue valueWithRange:NSMakeRange(0, 3)],  // Epidemiología
                                [NSValue valueWithRange:NSMakeRange(3, 3)],  // Brilinta
                                [NSValue valueWithRange:NSMakeRange(6, 3)],  // Eficacia
                                [NSValue valueWithRange:NSMakeRange(9, 1)],  // Seguridad
                                [NSValue valueWithRange:NSMakeRange(10, 2)], // Posología
                                nil];
        
        documentTitles = [NSArray arrayWithObjects:
                          @"Apertura",
                          @"Epidemiología",
                          @"Riesgo",
                          @"Director",
                          @"Indicaciones",
                          @"Mecanismo de acción",
                          @"Rapidez de acción",
                          @"Eficacia",
                          @"Mantenimiento",
                          @"Seguridad",
                          @"Dosis",
                          @"Cierre",
                          nil];
    }
    return self;
}

- (NSUInteger)numberOfDocuments
{
    return 12;
}

- (NSString *)titleForDocumentAtIndex:(NSUInteger)index
{
    return [documentTitles objectAtIndex:index];
}

- (UIView<ContentControlProtocol> *)viewForDocumentAtIndex:(NSUInteger)index
{
    NSString *slideName = [@"slide" stringByAppendingString:[[NSNumber numberWithUnsignedInt:index + 1] stringValue]];
    NSString *path = [[NSBundle mainBundle] pathForResource:slideName
                                                     ofType:@"html"
                                                inDirectory:[@"slides/" stringByAppendingString:slideName]];
    
    if (!path)
        return nil;
    
    NSURL *url = [NSURL URLWithString: [path lastPathComponent] 
                        relativeToURL: [NSURL fileURLWithPath: [path stringByDeletingLastPathComponent] 
                                                  isDirectory: YES]];
    
    [webContentView loadRequest:[NSURLRequest requestWithURL:url]];
    webContentView.scalesPageToFit = YES;
    return webContentView;
}

- (UIView<ContentControlProtocol> *)viewForPDF:(NSString *)pdf
{
    
    //UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, 200, 200)];
    NSString *path = [[NSBundle mainBundle] pathForResource:pdf ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [webContentView loadRequest:[NSURLRequest requestWithURL:url]];
    return webContentView;
}

- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index
{
    NSString *fileName = [[@"brilinta_" stringByAppendingString:[NSNumber numberWithUnsignedInt:index + 1].stringValue] stringByAppendingString:@".jpg"];
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
}

- (NSDictionary *)annotationsForDocumentAtIndex:(NSUInteger)index
{
    return [documentAnnotations objectForKey:[NSNumber numberWithUnsignedInt:index]];
}

- (void)setAnnotations:(NSDictionary *)annotations forDocumentAtIndex:(NSUInteger)index
{
    [documentAnnotations setObject:annotations forKey:[NSNumber numberWithUnsignedInteger:index]];
}

- (NSRange)rangeForCategoryIndex:(NSUInteger)categoryIndex
{
    return [[categoriesAndIndices objectAtIndex:categoryIndex] rangeValue];
}

- (NSUInteger)categoryIndexForDocumentAtIndex:(NSUInteger)documentIndex
{
    for (NSValue *value in categoriesAndIndices)
        if (NSLocationInRange(documentIndex, [value rangeValue]))
            return [categoriesAndIndices indexOfObject:value];
    
    return NSUIntegerMax;
}

// Delegation
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    webContentView.hidden=YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self performSelector:@selector(delay) withObject:nil afterDelay:.5];
    
    
}

- (void)delay{
    
    [self.delegate contentViewDidFinishLoad];
    webContentView.hidden=NO;
}

@end
