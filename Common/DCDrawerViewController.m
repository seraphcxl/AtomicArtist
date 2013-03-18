//
//  DCDrawerViewController.m
//  
//
//  Created by Chen XiaoLiang on 13-3-18.
//
//

#import "DCDrawerViewController.h"
#import "DCViewCtrlStub.h"

@interface DCDrawerViewController ()

@end

@implementation DCDrawerViewController

@synthesize innerViewCtrlStubs = _innerViewCtrlStubs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @synchronized(self) {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
            // Custom initialization
            _innerViewCtrlStubs = [NSMutableDictionary dictionary];
            SAFE_ARC_RETAIN(_innerViewCtrlStubs);
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            if (self.innerViewCtrlStubs) {
                [self.innerViewCtrlStubs removeAllObjects];
                SAFE_ARC_SAFERELEASE(_innerViewCtrlStubs);
            }
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)viewDidLoad {
    do {
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        @synchronized(self.innerViewCtrlStubs) {
            for (DCViewCtrlStub *stub in self.innerViewCtrlStubs) {
                if (stub && stub.viewCtrl) {
                    [stub.viewCtrl viewDidLoad];
                }
            }
        }
    } while (NO);
}

- (void)viewWillAppear:(BOOL)animated {
    do {
        [super viewWillAppear:animated];
        @synchronized(self.innerViewCtrlStubs) {
            for (DCViewCtrlStub *stub in self.innerViewCtrlStubs) {
                if (stub && stub.viewCtrl) {
                    [stub.viewCtrl viewWillAppear:animated];
                }
            }
        }
    } while (NO);
}

- (void)viewDidAppear:(BOOL)animated {
    do {
        [super viewDidAppear:animated];
        @synchronized(self.innerViewCtrlStubs) {
            for (DCViewCtrlStub *stub in self.innerViewCtrlStubs) {
                if (stub && stub.viewCtrl) {
                    [stub.viewCtrl viewDidAppear:animated];
                }
            }
        }
    } while (NO);
}

- (void)viewWillDisappear:(BOOL)animated {
    do {
        @synchronized(self.innerViewCtrlStubs) {
            for (DCViewCtrlStub *stub in self.innerViewCtrlStubs) {
                if (stub && stub.viewCtrl) {
                    [stub.viewCtrl viewWillDisappear:animated];
                }
            }
        }
        [super viewWillDisappear:animated];
    } while (NO);
}

- (void)viewDidDisappear:(BOOL)animated {
    do {
        @synchronized(self.innerViewCtrlStubs) {
            for (DCViewCtrlStub *stub in self.innerViewCtrlStubs) {
                if (stub && stub.viewCtrl) {
                    [stub.viewCtrl viewDidDisappear:animated];
                }
            }
        }
        [super viewDidDisappear:animated];
    } while (NO);
}

- (void)didReceiveMemoryWarning {
    do {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
        @synchronized(self.innerViewCtrlStubs) {
            for (DCViewCtrlStub *stub in self.innerViewCtrlStubs) {
                if (stub && stub.viewCtrl) {
                    [stub.viewCtrl didReceiveMemoryWarning];
                }
            }
        }
    } while (NO);
}

- (void)insertView:(UIView *)aView inViewCtrl:(UIViewController *)aViewCtrl {
    do {
        if (!aView || !aViewCtrl || !self.innerViewCtrlStubs) {
            break;
        }
        DCViewCtrlStub *stub = [[DCViewCtrlStub alloc] initWithView:aView inViewCtrl:aViewCtrl];
        SAFE_ARC_AUTORELEASE(stub);
        @synchronized(self.innerViewCtrlStubs) {
            [self.innerViewCtrlStubs setObject:stub forKey:stub.uniqueID];
        }
    } while (NO);
}

- (void)removeView:(UIView *)aView inViewCtrl:(UIViewController *)aViewCtrl {
    do {
        if (!aView || !aViewCtrl || !self.innerViewCtrlStubs) {
            break;
        }
        NSString *uniqueID = [DCViewCtrlStub uniqueIDForViewCtrl:aViewCtrl];
        @synchronized(self.innerViewCtrlStubs) {
            [self.innerViewCtrlStubs removeObjectForKey:uniqueID];
        }
    } while (NO);
}

@end
