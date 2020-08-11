//
//  ViewController.m
//  LZZJson2OCObject
//
//  Created by Chemm_Luzz on 2020/8/10.
//  Copyright © 2020 Chemm. All rights reserved.
//

#import "ViewController.h"
#import "SingleTonInfo.h"
#import "JsonToModelTool.h"
#import <Security/Security.h>


#define NS_HAS_PERMISSION_ERROR(error) (error.code == NSFileReadNoPermissionError || error.code == NSFileWriteNoPermissionError)

#define kStrHasText(str) (str!=nil && ![str isKindOfClass:[NSNull class]] && ![str isEqualToString:@""])
#define kStringF(str) str==nil?@"":[NSString stringWithFormat:@"%@",str]

@interface ViewController()
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@property (weak) IBOutlet NSTextField *rootPreTf;
@property (weak) IBOutlet NSTextField *commonPrefixTf;
@property (weak) IBOutlet NSButton *pathBtn;


//@property (weak) IBOutlet NSButton *pathBtn;
//@property (weak) IBOutlet NSTextField *commonPrefixTf;
//@property (weak) IBOutlet NSTextField *rootPreTf;


@end

@implementation ViewController

#pragma mark - 页面操作


- (void)dealloc
{
    [self removeObserver:self forKeyPath:kSel(dirPath)];
    [self removeObserver:self forKeyPath:kSel(rootPrefix)];
    [self removeObserver:self forKeyPath:kSel(commonPrefix)];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.commonPrefixTf];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.rootPreTf];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSParsingErrorNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    NSString * jsonString = [[NSUserDefaults standardUserDefaults] valueForKey:@"json_string"];
    if (jsonString) {
        self.textView.string = jsonString;
    }
    
    __weak typeof(self)weakSelf = self;
    [[SingleTonInfo sharedInstance] addObserver:weakSelf forKeyPath:kSel(dirPath) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [[SingleTonInfo sharedInstance] addObserver:weakSelf forKeyPath:kSel(rootPrefix) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [[SingleTonInfo sharedInstance] addObserver:weakSelf forKeyPath:kSel(commonPrefix) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(textFieldEditDidChanged:) name:NSControlTextDidChangeNotification object:self.commonPrefixTf];
    [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(textFieldEditDidChanged:) name:NSControlTextDidChangeNotification object:self.rootPreTf];
    [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(showErrorAlertAction:) name:NSParsingErrorNotification object:nil];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kSel(dirPath)]) {
        NSString * path = [change objectForKey:NSKeyValueChangeNewKey];
        NSString * titleStr = kStrHasText(path)?@"Output Folder: ":@"Choose An Output Folder";
        NSMutableAttributedString * btn_title = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:titleStr attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:12],NSForegroundColorAttributeName:[NSColor blueColor]}]];
        if (kStrHasText(path)) {
            [btn_title appendAttributedString:[[NSAttributedString alloc] initWithString:path attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:12],NSForegroundColorAttributeName:[NSColor redColor]}]];
        }
        [self.pathBtn setAttributedTitle:btn_title];
    } else if([keyPath isEqualToString:kSel(commonPrefix)]){
        NSString * prefixStr = [change objectForKey:NSKeyValueChangeNewKey];
        self.commonPrefixTf.stringValue = prefixStr;
        
    }else if([keyPath isEqualToString:kSel(rootPrefix)]){
        NSString * prefixStr = [change objectForKey:NSKeyValueChangeNewKey];
        self.rootPreTf.stringValue = prefixStr;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


-(void)textFieldEditDidChanged:(NSNotification *)sender
{
    if ([sender.object isEqual:self.commonPrefixTf]) {
        [SingleTonInfo sharedInstance].commonPrefix = self.commonPrefixTf.stringValue;
    }else if ([sender.object isEqual:self.rootPreTf]){
        [SingleTonInfo sharedInstance].rootPrefix = self.rootPreTf.stringValue;
    }
}

-(void)showErrorAlertAction:(NSNotification *)sender
{
    NSString * errorDesc = [sender.userInfo objectForKey:NSLocalizedDescriptionKey];
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = errorDesc;
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}



- (IBAction)pathBtnClickAction:(id)sender {
    [self chooseDirPath:nil];
}

// 选择路径
-(void)chooseDirPath:(void(^)(NSString * path))completion
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.prompt = @"OK";
    openPanel.title = @"Select";
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    openPanel.canChooseFiles = NO;
    BOOL okButtonPressed = ([openPanel runModal] == NSModalResponseOK);
    if(okButtonPressed) {
        NSString * path = [[openPanel URL] path];
        [SingleTonInfo sharedInstance].dirPath = path;
        if (completion) {
            completion(path);
        }
    }
}

// 点击提交
- (IBAction)transformBtnClickAction:(id)sender {
    __weak typeof(self)weakSelf = self;
    if (kStrHasText(kDirPath)) {
        if ([self checkDirPath]) {
            [weakSelf checkDirPathHasOtherObject];
        }else{
            [self chooseDirPath:^(NSString *path) {
                [weakSelf checkDirPathHasOtherObject];
            }];
        }
    }else{
        [self chooseDirPath:^(NSString *path) {
            [weakSelf checkDirPathHasOtherObject];
        }];
    }
}

// 检查路径是否合法
-(BOOL)checkDirPath
{
    BOOL isDir;
    BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:kDirPath isDirectory:&isDir];
    BOOL flag = (isDir && isExit);
    if (flag) {
        BOOL writable = [[NSFileManager defaultManager] isWritableFileAtPath:kDirPath];
        if (writable == NO) {
            NSAlert * alert = [[NSAlert alloc] init];
            alert.messageText = @"No Permission To Write In This Folder";
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSAlertStyleInformational];
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        }
    }
    return flag;
}

// 检测文件夹是否有其他OC文件
-(void)checkDirPathHasOtherObject
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kDirPath error:NULL];
    
    NSMutableArray * ocObjcs = [NSMutableArray array];
    for (NSString * obj in contents) {
        if ([obj hasSuffix:@"h"] || [obj hasSuffix:@"m"]) {
            [ocObjcs addObject:obj];
        }
    }
    
    if (ocObjcs.count>0) {
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = @"This folder contains other Objective-C files,are you going to clean them?";
        [alert addButtonWithTitle:@"Clean"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSAlertFirstButtonReturn){
                NSEnumerator *e = [ocObjcs objectEnumerator];
                NSString *filename;
                while ((filename = [e nextObject])) {
                    [[NSFileManager defaultManager] removeItemAtPath:[kDirPath stringByAppendingPathComponent:filename] error:NULL];
                }
                [self saveToDirPath];
            }else if(returnCode == NSAlertSecondButtonReturn){
                [self saveToDirPath];
            }
        }];
    }else{
        [self saveToDirPath];
    }
}





// 确认一切正常后进行的数据解析
-(void)saveToDirPath
{
    NSDictionary * dict = [self checkJsonValidate];
    if (dict) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:NULL];
        NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.textView.string = dataStr;
        kUserDefaultSave(self.textView.string, @"json_string"); // 将这次合法的json保存好
    
        [JsonToModelTool parseRootJsonWithDict:dict];
        [self successAlert];
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Json content is invalid!!!";
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    }
}

-(void)successAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Successed!";
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Open Target Finder"];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertSecondButtonReturn){
            NSLog(@"open file:%@",kDirPath);
            [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:kDirPath isDirectory:YES]];
        }
    }];
}


// 检查json是否合法
-(id)checkJsonValidate
{
    NSString * jsonString = self.textView.string;
    if (jsonString) {
        NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData) {
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:NULL];
            return dict;
        }
    }
    return nil;
}



@end
