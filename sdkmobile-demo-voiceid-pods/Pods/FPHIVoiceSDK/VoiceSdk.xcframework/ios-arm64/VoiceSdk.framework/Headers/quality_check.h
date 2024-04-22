/* Copyright 2023 ID R&D Inc. All Rights Reserved. */

/*!
 @header quality_check.h
 @brief Quality check engine header file.
 */

#import <Foundation/Foundation.h>

/*!
 @brief Enumeration representing short quality check description
 */
typedef NS_ENUM(NSInteger, QualityCheckShortDescription) {
    /*!
     @brief Too noisy audio.
     */
    QUALITY_SHORT_DESCRIPTION_TOO_NOISY = 0,

    /*!
     @brief Too small speech length in the audio.
     */
    QUALITY_SHORT_DESCRIPTION_TOO_SMALL_SPEECH_TOTAL_LENGTH = 1,

    /*!
     * @brief Audio successfully passed quality check.
     */
    QUALITY_SHORT_DESCRIPTION_OK = 2
};

__attribute__((visibility("default")))
/*!
 @interface QualityCheckMetricsThresholds
 @brief Represents quality checking thresholds
 */
@interface QualityCheckMetricsThresholds : NSObject

/*!
 @brief Minimum signal-to-noise ratio required to pass quality check in dB.
 */
@property(assign, nonatomic) float minimumSnrDb;

/*!
 @brief Minimum speech length required to pass quality check in milliseconds.
 */
@property(assign, nonatomic) float minimumSpeechLengthMs;

@end

__attribute__((visibility("default")))
/*!
 @interface QualityCheckEngineResult
 @brief Represents audio quality check result.
 */
@interface QualityCheckEngineResult : NSObject

/*!
 @brief SNR metric value obtained on quality check in Db.
 */
@property(assign, nonatomic) float snrDb;

/*!
 @brief Speech length metric value obtained on quality check in milliseconds.
 */
@property(assign, nonatomic) float speechLengthMs;

/*!
 @brief Short description of the quality check results
 */
@property(assign, nonatomic) QualityCheckShortDescription qualityCheckShortDescription;

@end

__attribute__((visibility("default")))
/*!
 @interface QualityCheckEngine
 @brief Class for audio quality checking.
 */
@interface QualityCheckEngine : NSObject

/*!
 @brief Creates QualityCheckEngine instance.
 @param initPath initialization data path
 @param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithPath:(NSString* _Nonnull)initPath error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Checks whether audio buffer is suitable from the quality perspective, from the given PCM16 audio samples.
 @param PCM16Samples PCM16 audio data
 @param sampleRate audio sample rate
 @param thresholds quality checking thresholds that will be applied to the output quality check metrics
 @param error pointer to NSError for error reporting
 @return Quality check result.
 */
- (QualityCheckEngineResult* _Nullable)checkQuality:(NSData* _Nonnull)PCM16Samples
                                   sampleRate:(size_t)sampleRate
                                   thresholds:(QualityCheckMetricsThresholds* _Nonnull)thresholds
                                        error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief  Checks whether WAV file is suitable from the quality perspective, from the given audio file.
 @param wavPath path to WAV file
 @param thresholds quality checking thresholds that will be applied to the output quality check metrics
 @param error pointer to NSError for error reporting
 @return Quality check result.
 */
- (QualityCheckEngineResult* _Nullable)checkQuality:(NSString* _Nonnull)wavPath
                                   thresholds:(QualityCheckMetricsThresholds* _Nonnull)thresholds
                                        error:(NSError* _Nullable* _Nullable)error;

@end