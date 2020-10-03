Copyright (C) 2017 Gaurav Nakum (Indian Institute of Technology Guwahati)

This project was completed at Electrical Engineering Department of Hanyang University, South Korea under the mentorship of:
Minsik Lee, Professor, Electrical Engineering, Hanyang University
Frank Chung-Hoon Rhee, Professor, Electrical Engineering, Hanyang University
Nikhil Yadala, Computer Science and Engineering, Indian Institute of Technology Guwahati

This code is an implementation of the methods described in:


[1] Minsik Lee and Chong-Ho Choi,
    "Fast Facial Shape Recovery From a Single Image With General, Unknown Lighting by Using Tensor Representation,"
    Pattern Recognition, vol. 44, no. 7, pp. 1487-1496, Jul. 2011.
[2] Minsik Lee and Chong-Ho Choi,
    "A Robust Real-Time Algorithm for Facial Shape Recovery From a Single Image Containing Cast Shadow Under General, Unknown Lighting,"
    Pattern Recognition, vol. 46, no. 1, pp. 38-44, Jan. 2013.
[3] Minsik Lee and Chong-Ho Choi,
    "Real-time Facial Shape Recovery From a Single Image under General, Unknown Lighting by Rank Relaxation,"
    Computer Vision and Image Understanding, vol. 120, pp. 59-69, Mar. 2014.
[4] Minsik Lee,
    "Facial Shape Recovery from a Single Image with General, Unknown Lighting,"
    Ph.D. dissertation, Seoul National University, Feb. 2012.

This software is distributed WITHOUT ANY WARRANTY. Use of this software is 
granted for research conducted at research institutions only. Commercial use
of this software is not allowed. Corporations interested in the use of this
software should contact the authors. If you use this code for a scientific
publication, please cite the above paper.

USAGE:

Please see the demo files "demo.m" for usage information. These scripts were
tested with MATLAB versions R2017b.

FEEDBACK:

Your feedback is greatly welcome. Please send bug reports, suggestions, and/or
new results to:

    nakumgaurav25@gmail.com

CONTENTS: (will be updated soon)

    README.txt:                         This file.
    gpl.txt:                            License information.
    demo.m:                             Demo program.
    preprocess.m:                       Preprocessing script. (Run this script first.)
    train_TR.m:                         Training script for [1].
    train_NIM.m:                        Training script for [2].
    train_RR.m:                         Training script for [3].
    recon_TR.m:                         Reconstruction code for [1].
    recon_NIM.m:                        Reconstruction code for [2].
    recon_RR.m:                         Reconstruction code for [3].
    depth2sn.m:                         Calculate surface normal map from depth map.
    sn2img.m:                           Render image without cast shadow.
    plamb.m:                            Render image with cast shadow.
    MMSE_alb.m:                         MMSE filtering for albedo calculation.
    fill_nuclear.m:                     Fill missing entries.
    warp_img.m:                         Perform image warping.
    get_affine_tr.m:                    Calculate affine transform.
    Nproduct.m:                         Mode-k product.
    TensorDecomposition.m:              Perform HOSVD (N-mode SVD).
    TensorTrim.m:                       Truncate HOSVD result.
    hyperspherical.m:                   Convert to hyperspherical coordinates.
    lightdir.mat:                       200 evenly distributed light directions.
    MinsikLee.jpg:                      Sample image.
    data/:                              Directory for training data.
    pre/:                               Directory for preprocessed data.
    model/:                             Directory for trained models.
