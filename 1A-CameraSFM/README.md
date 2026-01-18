The dataset.txt file contains:
 - camera poses (lines denoted by KF)
 - keypoints in camera image (lines denoted by F)
 
These lines contain the camera id (first number), the GT camera pose (second 6 numbers) and the estimate of our system (last 6 numbers, you can ignore). The 6 numbers containg the camera pose refer to:
- first 3 numbers as translation
- last 3 numbers as the imaginary part of unit quaternion (no qw). You can reconstruct the whole quaternion (4 components) in the following way 
	quat -> is the imaginary part of quaternion (qx, qy, qz)
	n = squaredNorm(quat)
	if (n > 1)
	 return [1, 0, 0, 0];
	qw = sqrt(1 - n);
	full_quat = [qw, quat(1), quat(2), quat(3)]; 

Bear in mind that you don't need camera poses for this project. Camera poses here, is only helpful to delimit group of keypoints. 

The order is the following:
- camera pose
- set of keypoints belonging to the camera pose above

The keypoint entry contains information about: 
	- first number, progressive id of the keypoint in the image
	- second number, unique identifier good for data assocition :D
	- third number, direction vector (it's the inverse projection of the keypoint). Skip the inverse projection and use direction vector for the essential matrix.
	
Evaluation of your poses:
Since the dataset recording doesn't start at the origin, evaluate your solution comparing it with the gt using the delta rotation between poses.

For example, suppose we have two associated poses:
KF 0 x x x a  b  c
KF 1 x x x a' b' c'
- compute the delta rotation between the two poses, R_delta = R(a,b,c)^T  * R(a',b',c')
- compare it with delta of your solution in this way trace(eye(3) - R_delta^T * R_delta_gt)


