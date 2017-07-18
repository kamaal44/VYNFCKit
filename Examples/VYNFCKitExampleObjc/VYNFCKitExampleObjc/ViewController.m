//
//  ViewController.m
//  VYNFCKitExampleObjc
//
//  Created by Vince Yuan on 7/11/17.
//  Copyright © 2017 Vince Yuan. All rights reserved.
//

#import "ViewController.h"
#import <CoreNFC/CoreNFC.h>
#import <VYNFCKit/VYNFCKit.h>

@interface ViewController () <NFCNDEFReaderSessionDelegate> {
    NSString *_results;
    __weak IBOutlet UITextView *_textViewResults;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapScanNFCTagButton:(id)sender {
    _results = @"";
    _textViewResults.text = @"";
    NFCNDEFReaderSession *session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:dispatch_get_main_queue() invalidateAfterFirstRead:NO];
    [session beginSession];
}

#pragma mark - NFCNDEFReaderSessionDelegate

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages {
    for (NFCNDEFMessage *message in messages) {
        for (NFCNDEFPayload *payload in message.records) {
            id parsedPayload = [VYNFCNDEFPayloadParser parse:payload];
            if (parsedPayload) {
                NSString *text = @"";
                if ([parsedPayload isKindOfClass:[VYNFCNDEFTextPayload class]]) {
                    text = ((VYNFCNDEFTextPayload *)parsedPayload).text;
                } else if ([parsedPayload isKindOfClass:[VYNFCNDEFURIPayload class]]) {
                    text = ((VYNFCNDEFURIPayload *)parsedPayload).URIString;
                } else if ([parsedPayload isKindOfClass:[VYNFCNDEFTextXVCardPayload class]]) {
                    text = ((VYNFCNDEFTextXVCardPayload *)parsedPayload).text;
                } else if ([parsedPayload isKindOfClass:[VYNFCNDEFSmartPosterPayload class]]) {
                    VYNFCNDEFSmartPosterPayload *sp = parsedPayload;
                    for (VYNFCNDEFTextPayload *textPayload in sp.payloadTexts) {
                        text = [NSString stringWithFormat:@"%@%@\n", text, textPayload.text];
                    }
                    text = [NSString stringWithFormat:@"%@%@", text, sp.payloadURI.URIString];
                }
                NSLog(@"%@", text);
                _results = [NSString stringWithFormat:@"%@%@\n", _results, text];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _textViewResults.text = _results;
                });
            }
        }
    }
}

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error {
    NSLog(@"%@", error);
    _results = [NSString stringWithFormat:@"%@%@\n", _results, error];
    dispatch_async(dispatch_get_main_queue(), ^{
        _textViewResults.text = _results;
    });
}



@end
