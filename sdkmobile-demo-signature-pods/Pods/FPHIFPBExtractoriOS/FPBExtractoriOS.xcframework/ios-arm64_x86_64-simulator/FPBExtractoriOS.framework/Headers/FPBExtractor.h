#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "FPBExtractionResult.h"
#import "FPBExtractorConfigurationManager.h"
#import "FPBTemplateInfo.h"
#import "FPBExtractionMode.h"
#import "FPBLivenessTimerDiagnostic.h"
#import "FPBLivenessResult.h"
#import "FPBExtractionOptions.h"
#import "FPBLivenessTimer.h"

/**
	This module will be responsible for providing the functions associated with the extraction of facial templates.
	<p>
	This class provides methods to perform the pattern extraction process from a sequence of images.
	</p>
	<p>
	The sequence of operations to perform this process is, firstly, initialize the extraction process
	by calling the <b>InitStreamExtraction</b> method specifying the number of images which composes
	the images extraction sequence. Secondly, the images of the sequence should be processed one by one by using the
	<b>ExtractNext</b> method.
	</p>
	<p>
	The sequence of operations to perform this process is, firstly, initialize the extraction process
	by calling the <b>InitStreamExtraction</b> method specifying the number of images which composes
	the images extraction sequence. Secondly, the images of the sequence should be processed one by one by using the
	<b>ExtractNext</b> method.
	</p>
	<p>
	In case that the extraction process had already been initialized and someone wish to abort
    it to start a new one, the first step is to abort the current
    extraction process by calling the <b>StopStreamExtraction</b> method, otherwise the system will
    return an exception.
	</p>
*/
@interface FPBExtractor : NSObject<NSCopying>

/**
	Initializes a new instance of the {@link FPBExtractor} class with a configuration {@link FPBExtractorConfigurationManager}.
	@param ecm Extractor configuration @see ExtractorConfigurationManager.
*/
- (id)init:(FPBExtractorConfigurationManager *) ecm;

/**
	Indicates if exists an ongoing template generation process.
*/    
@property (nonatomic, readonly) bool initiated;

/**
	Initializes the pattern extraction and template creation process specifying the minimum number of patterns required and the number of samples used.
	<p>
		This method must be called before the extraction of the patterns. It is necessary to
		specify the minimum number of valid patterns required to succeed in the extraction process
		and the number of images in the image sequence used.
	</p>
	@param minimumPatternNumber Minimum number of valid patterns required to generate a correct template.
	@param samples Number of samples or images which makes up the extraction sequence.
	@param outError
		<ul>
			<li>The minimum number of valid patterns specified is less than 1 and greater than the number of samples specified.</li>
			<li>The number of samples specified is less than 1.</li>
			<li>There is already an ongoing extraction process.</li>
		</ul>
*/
-(void)initStreamExtraction:(int)minimumPatternNumber withNumSamples:(int)samples outError:(NSError **)outError;

/**
	Initializes the pattern extraction and template creation process specifying the number of samples required.
	<p>
		This method must be called before the extraction of the patterns. It is necessary to
		specify the minimum number of valid patterns required to succeed in the extraction process
		and the number of images in the image sequence used.
	</p>
	<p>This method is equivalent to InitStreamExtraction(1, samples)</p>
	@param samples Number of samples or images which makes up the extraction sequence.
	@param outError
		<ul>
			<li>The minimum number of valid patterns specified is less than 1 and greater than the number of samples specified.</li>
			<li>The number of samples specified is less than 1.</li>
			<li>There is already an ongoing extraction process.</li>
		</ul>
*/
-(void)initStreamExtraction:(int)samples outError:(NSError **)outError;

/**
	Stops the facial pattern extraction process.
*/
-(void)stopStreamExtraction:(NSError **)outError;

/**
	Performs the facial features detection from an specific image.
	@param image Image from which the detection will be performed.
	@param outError
		<ul>
			<li>The specified image has an invalid format.</li>
			<li>The number of samples specified is less than 1.</li>
			<li>An internal error during the detection process has occurred.</li>
		</ul>
	@return Result of the extraction process which contains the results of the detection process.
	@see ExtractionResult.
*/
-(NSArray<FPBExtractionResult*> *)detect:(UIImage *)image outError:(NSError **)outError;

/**
	Performs an extraction of facial features from an specific image.
	@param image Image from which the facial pattern will be extracted.
	@param outError
		<ul>
			<li>The specified image has an invalid format.</li>
			<li>The number of samples specified is less than 1.</li>
			<li>An internal error during the detection process has occurred.</li>
		</ul>
	@return Result of the extraction process which contains the results of the detection process.
	@see ExtractionResult.
*/
-(NSArray<FPBExtractionResult*> *)extractNext:(UIImage *)image outError:(NSError **)outError;

/**
	Performs an extraction of facial features of the face represented by the eyes position specified as parameters.
	@param image Image from which the detection will be performed.
	@param leftEye Left eye position of the individual from which the face pattern is desired to be extracted (from the individual point of view).
	@param rightEye Right eye position of the individual from which the face pattern is desired to be extracted (from the individual point of view).
	@param outError
		<ul>
			<li>The specified image has an invalid format.</li>
			<li>The number of samples specified is less than 1.</li>
			<li>An internal error during the detection process has occurred.</li>
		</ul>
	@return Result of the extraction process which contains the results of the detection process.
	@see ExtractionResult.
*/
-(FPBExtractionResult *)extractNext:(UIImage *)image withLeftEye:(CGPoint)leftEye withRightEye:(CGPoint)rightEye outError:(NSError **)outError;

/**
    Gets the information of several templates.
    @param templatesData Templates data.
	@param outError Error.
    @return Template info.
 */
-(FPBTemplateInfo *)evaluateTemplates:(NSArray *)templatesData outError:(NSError **)outError;

/**
    Gets the extractor version.
    @return Extractor version.
 */
+(NSString *)getVersion;

/**
	Initializes the pattern extraction and template creation process.
	<p>
     This method must be called before the extraction of the patterns.
	</p>
	@param extractionMode Extraction mode.
	@param outError
     <ul>
     <li>There is already an ongoing extraction process.</li>
     </ul>
 */
-(void)initStreamExtractionSmart:(FPBExtractionMode)extractionMode outError:(NSError **)outError;

/**
 Initializes the pattern extraction and template creation process.
 <p>
 This method must be called before the extraction of the patterns.
 </p>
 @param extractionOptions Extraction options.
 @param outError
 <ul>
 <li>There is already an ongoing extraction process.</li>
 </ul>
 */
-(void)initStreamExtractionSmartWithExtractionOptions:(FPBExtractionOptions*)extractionOptions outError:(NSError **)outError;

/**
	Performs an extraction of facial features of the face represented by the eyes position specified as parameters.
	@param image Image from which the detection will be performed.
	@param outError
     <ul>
     <li>The specified image has an invalid format.</li>
     <li>An internal error during the detection process has occurred.</li>
     </ul>
	@return Result of the extraction process which contains the results of the detection process.
	@see ExtractionResult.
 */
-(FPBExtractionResult *)extractNextSmart:(UIImage *)image outError:(NSError **)outError;

/**
	Performs a liveness evaluation from a list of images.
	@param images List of images to evaluate liveness.
	@param livenessTimerDiagnostic Diagnostic of liveness timer.
	@param templateReference Template reference.
	@param outError
     <ul>
     <li>Invalid images.</li>
     <li>Invalid liveness diagnostic.</li>
     <li>An internal error during the detection process has occurred.</li>
     </ul>
     @return Liveness result.
*/
// -(FPBLivenessResult *)evaluateLiveness:(NSArray *)images withLivenessDiagnostic:(FPBLivenessTimerDiagnostic*)livenessTimerDiagnostic withTemplateReference:(NSData*)templateReference outError:(NSError **)outError;

/**
 Initializes a liveness sequence stabilization.
 @param outError An error occurred.
 */
-(void)initLivenessHMCCStabilization:(NSError **)outError;

/**
    Initializes a liveness sequence stabilization.
    @param extractionOptions Extraction options.
    @param outError An error occurred.
 */
-(void)initLivenessHMCCStabilization:(FPBExtractionOptions*)extractionOptions outError:(NSError **)outError;

/**
    Next liveness sequence stabilization.
    @param image Image.
    @param milliseconds Milliseconds.
    @param outError An error occurred.
    @return Extraction result.
 */
-(FPBExtractionResult*)nextLivenessHMCCStabilization:(UIImage *)image withMilliseconds:(int)milliseconds outError:(NSError **)outError;

/**
 Initializes a liveness sequence evaluation process.
 @param extractionOptions Extraction options.
 @param outError An error occurred.
 */
// -(void)initLivenessHMCCSequence:(FPBExtractionOptions*)extractionOptions outError:(NSError **)outError;

/**
 Next liveness sequence evaluation process.
 @param outError An error occurred.
 @return Liveness result.
 */
// -(FPBLivenessResult*)nextLivenessHMCCSequence:(NSError **)outError;

/**
 Next liveness image for sequence evaluation process.
 @param image Image.
 @param outError An error occurred.
 */
// -dir5e4(FPBExtractionResult*)nextLivenessHMCCImage:(UIImage *)image outError:(NSError **)outError;

/**
 Evaluates liveness sequence process.
 @param livenessTimer Liveness timer.
 @param outError An error occurred.
 */
// -(FPBExtractionResult*)evaluateLivenessHMCChallenge:(FPBLivenessTimer*)livenessTimer outError:(NSError **)outError;

/**
Tokenize data.
@param data Raw data.
@param outError An error occurred.
@return Tokenized raw data.
 */
-(NSData *)tokenize:(NSData*)data outError:(NSError **)outError;

@end
