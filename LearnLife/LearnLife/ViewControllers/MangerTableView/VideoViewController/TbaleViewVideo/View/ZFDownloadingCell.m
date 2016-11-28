
#import "ZFDownloadingCell.h"

@implementation ZFDownloadingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)clickDownloadBtn:(id)sender {
    // 执行操作过程中应该禁止该按键的响应 否则会引起异常
//    sender.userInteractionEnabled = NO;
    self.downloadButton.userInteractionEnabled = NO;

    ZFFileModel *downFile = self.fileInfo;
    ZFDownloadManager *filedownmanage = [ZFDownloadManager sharedDownloadManager];
    if(downFile.downloadState == ZFDownloading) { //文件正在下载，点击之后暂停下载 有可能进入等待状态
        self.downloadButton.selected = YES;
        [filedownmanage stopRequest:self.request];
    } else {
        self.downloadButton.selected = NO;
        [filedownmanage resumeRequest:self.request];
    }
    
    // 暂停意味着这个Cell里的ASIHttprequest已被释放，要及时更新table的数据，使最新的ASIHttpreqst控制Cell
    if (self.btnClickBlock) {
        self.btnClickBlock();
    }
    self.downloadButton.userInteractionEnabled = YES;
}

- (void)setFileInfo:(ZFFileModel *)fileInfo
{
    _fileInfo = fileInfo;
    self.fileNameLabel.text = fileInfo.fileName;
    // 服务器可能响应的慢，拿不到视频总长度
    if ([fileInfo.fileSize longLongValue] == 0) {
        self.progressLabel.text = @"正在获取";
        self.speedLabel.text = @"0.00B/S";
        self.progress.progress = 0.0;
        return;
    }
    NSString *currentSize = [ZFCommonHelper getFileSizeString:fileInfo.fileReceivedSize];
    NSString *totalSize = [ZFCommonHelper getFileSizeString:fileInfo.fileSize];
    // 下载进度
    float progress = (float)[fileInfo.fileReceivedSize longLongValue] / [fileInfo.fileSize longLongValue];
    
    self.progressLabel.text = [NSString stringWithFormat:@"%@ / %@ (%.2f%%)",currentSize, totalSize, progress*100];
    
    self.progress.progress = progress;
    
    NSString *spped = [NSString stringWithFormat:@"%@/S",[ZFCommonHelper getFileSizeString:[NSString stringWithFormat:@"%lu",[ASIHTTPRequest averageBandwidthUsedPerSecond]]]];
    self.speedLabel.text = spped;
    
    if (fileInfo.downloadState == ZFDownloading) { //文件正在下载
        self.downloadButton.selected = NO;
    } else if (fileInfo.downloadState == ZFStopDownload&&!fileInfo.error) {
        self.downloadButton.selected = YES;
        self.speedLabel.text = @"已暂停";
    }else if (fileInfo.downloadState == ZFWillDownload&&!fileInfo.error) {
        self.downloadButton.selected = YES;
        self.speedLabel.text = @"等待下载";
    } else if (fileInfo.error) {
        self.downloadButton.selected = YES;
        self.speedLabel.text = @"错误";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
