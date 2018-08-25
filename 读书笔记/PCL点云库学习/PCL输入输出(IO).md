#I/O涉及的设备及相关概念简介
##OpenNI开源框架
OpenNI（开放式自然交互)来源于由业界领导的一个非营利性组织，创建于201。年11月，专注于提高和改善自然交互设备与应用软件的互操作能力。其官方网站于12月8号正式公开，主要成员之一是PrimeSense公司(Kinect的核心芯片正是由这家公司提供)，其他成员还包括开发ROS的机器人公司Willow Garage，以及游戏公司Side-Kick等。
OpenNI是一个多语言、跨平台的框架，它定义了一套用于编写通用自然交互应用的API。 OpenNI的主要目的就是形成标准的API，便于下面两个接口之间进行通信:

- 视觉和音频传感器(用来感知周围环境信息)。
- 视觉和音频感知中间件(用来对应用场景中所记录的音频和视觉数据进行分析与理解，例如能够接收一份可见的图像数据并返回从中检测到的手掌位置信息)。

OpenNI提供了一组基于传感器设备实现的API和另外一组由中间件组件实现的API，打破了传感器和中间件之间的依赖关系。这样，使用OpenNI API开发应用程序时就不需要在各种中间件模块的上层操作上浪费时间，可以做到一次编写、随处部署。OpenNI的这种分层设计机制允许中间件开发者可以直接基于最原始的数据格式编写算法，而不管这些数据是由何种传感器设备产生，同时也让传感器生产商制造的设备能用于任何OnenNI兼容的应用程序。
OpenNI的这套标准化API使得自然交互应用开发人员可以利用由传感器输人并计算过的数据类型，很方便地跟踪处理现实生活中的场景(例如，可以是表示人体全身的数据，也可以是表示手的位置数据，或者仅仅是深度图里面的一组像素等)。这样可以保证编写应用程序的时候，不用考虑传感器或中间件供应商相关的细节。
下图展示了OpenNI框架的应用概念，分为三层：

(1) 应用层:基于OpenNI实现的自然交互应用软件。     
(2) 中间件接口层:代表OpenNI本身，提供了传感器和中间件组件之间的交互接口。    
(3) 硬件设备层:列出了捕捉视觉和音频数据的多种硬件设备。
![](https://img-blog.csdn.net/20160104194428499)

##OpenNI兼容设备
Primesense Reference Design、Microsoft Kinect和Asus XtionPro这3种摄像头设备均进行了OpenNI兼容性测试。
![](http://pointclouds.org/assets/images/contents/documentation/io/openni.jpg)
#PCL中I/O模块及类介绍
21个类与28个函数实现了对点云的获取、读入、存储等相关操作其依赖于pcl_common和pcl_octree模块以及OpenNI外部开发包。
##I/O模块中类以及全局函数说明

- [class pcl::FileReader](http://docs.pointclouds.org/trunk/classpcl_1_1_file_reader.html)

类FileReader定义了PCD文件的读取接口，主要用做其他读取类的父类。

![](http://docs.pointclouds.org/trunk/classpcl_1_1_file_reader.png)

类FileReader的关键成员函数：
```c++
virtual int pcl::FileReader::readHeader (const std::string &  file_name,
                                         pcl::PCLPointCloud2 &   cloud,
                                         Eigen::Vector4f &   origin,
                                         Eigen::Quaternionf &    orientation,
                                         int &   file_version,
                                         int &   data_type,
                                         unsigned int &  data_idx,
                                         const int   offset = 0 
                                        )  
```
函数功能： 为纯虚函数Read a point cloud data header from a FILE file.
Load only the meta information (number of points, their types, etc), and not the points themselves, from a given FILE file. Useful for fast evaluation of the underlying data structure.

返回值: < 0 (-1) on error;> 0 on success

函数参数：

[in]    file_name   the name of the file to load 读取文件的文件名。

[out]   cloud   the resultant point cloud dataset (only the header will be filled) 存储读取后的点云数据，但只填充文件头

[out]   origin  the sensor acquisition origin (only for > FILE_V7 - null if not present) 点云获取原点，该参数只有在文件版本大于FILE_V7才存在，否则为NULL

[out]   orientation the sensor acquisition orientation (only for > FILE_V7 - identity if not present)
点云获取方向，该参数只有在文件版本大于FILE_V7才存在，否则为NULL

[out]   file_version    the FILE version of the file (either FILE_V6 or FILE_V7)
文件版本(FILE V7或者FILE V6)

[out]   data_type   the type of data (binary data=1, ascii=0, etc)
数据类型(二进制置为1, ASCII码置为0)

[out]   data_idx    the offset of cloud data within the file
数据偏移文件头末尾的偏移量。

[in]    offset  the offset in the file where to expect the true header to begin. One usage example for setting the offset parameter is for reading data from a TAR "archive containing multiple files: TAR files always add a 512 byte header in front of the actual file, so set the offset to the next byte after the header (e.g., 513).
文件头偏移文件开始的偏移量

```c++

int pcl::FileReader::read   (const std::string & file_name,
                             pcl::PCLPointCloud2 &   cloud,
                             const int   offset = 0 
)   
```
函数功能：为纯虚函数 Read a point cloud data from a FILE file (FILE_V6 only!) and store it into a pcl/PCLPointCloud2.

函数参数：

[in]    file_name   the name of the file containing the actual PointCloud data

[out]   cloud   the resultant PointCloud message read from disk

[out]   origin  the sensor acquisition origin (only for > FILE_V7 - null if not present)

[out]   orientation the sensor acquisition orientation (only for > FILE_V7 - identity if not present)

[out]   file_version    the FILE version of the file (either FILE_V6 or FILE_V7)

[in]    offset  the offset in the file where to expect the true header to begin. One usage example for setting the 
offset parameter is for reading data from a TAR "archive containing multiple files: TAR files always add a 512 byte header in front of the actual file, so set the offset to the next byte after the header (e.g., 513).

- [class pcl::FileWriter](http://docs.pointclouds.org/trunk/classpcl_1_1_file_writer.html)

![](http://docs.pointclouds.org/trunk/classpcl_1_1_file_writer.png)

类FileWriter关键成员函数：
```c++
int pcl::FileWriter::write  (   const std::string &     file_name,
                                const pcl::PCLPointCloud2::ConstPtr &   cloud,
                                const Eigen::Vector4f &     origin = Eigen::Vector4f::Zero (),
                                const Eigen::Quaternionf &  orientation = Eigen::Quaternionf::Identity (),
                                const bool  binary = false 
                            )  
```

函数功能：Save point cloud data to a FILE file containing n-D points.

函数参数：
[in]    file_name   the output file name 写入文件的文件名

[in]    cloud   the point cloud data message (boost shared pointer) 需要写入的点云对象

[in]    binary  set to true if the file is to be written in a binary FILE format, false (default) for ASCII 设置写入时的类型(true为二进制，false为ASCII码，默认为ASCII码)

[in]    origin  the sensor acquisition origin
写入文件头的点云获取原点，默认为(0,0,0,0)

[in]    orientation the sensor acquisition orientation
写入文件头的点云获取方向

- [class pcl::Grabber](http://docs.pointclouds.org/trunk/classpcl_1_1_grabber.html)

类Grabber为PCL1.X对应的设备驱动接口的基类定义

![](http://docs.pointclouds.org/trunk/classpcl_1_1_grabber.png)

具体用法见官方手册

- [class openni_wrapper::OpenNIDevice](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_open_n_i_device.html)

类OpenNIDevice定义openNI设备的基类，继承该基类可以实现不同的OpenNI设备子类，用于获取包括红外数据、RGB数据、深度图像数据等。
目前包括以下设备Primesense PSDK,  Microsoft Kinect,  Asus Xtion Pro/Live。

![](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_open_n_i_device.png)

- [class openni_wrapper::DeviceKinect](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_device_kinect.html)

- [class openni_wrapper::DevicePrimesense](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_device_primesense.html)

以上3个类分别封装了Kinect，Primesense，XtionPro相关设备操作和数据获取操作实现，其详细接口参考其父类OpenNIDevice的关键函数说明。

- [class openni_wrapper::DeviceONI](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_device_o_n_i.html)

封装了利用ONI文件回放虚拟类kinect设备的操作和数据获取操作实现，其详细接口参考其父类OpenNIDevice的关键函数说明。

- [class openni_wrapper::OpenNIDriver](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_open_n_i_driver.html)

类OpenNIDriver采用单例模式实现对底层驱动的封装，里面包含xn::Con-text对象，提供给所有设备使用。该类提供了枚举和访问所有设备的方法实现。

- [class openni_wrapper::OpenNIException](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_open_n_i_exception.html)

类OpenNIException封装一般的异常处理实现

- [class openni_wrapper::Image](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_image.html)

类Image是简单的图像数据封装基类

![](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_image.png)

- [class openni_wrapper::ImageBayerGRBG](http://docs.pointclouds.org/trunk/classopenni__wrapper_1_1_image_bayer_g_r_b_g.html)

- class openni_wrapper::ImageRGB24(1.8版本已经取消)

[class  pcl::io::ImageRGB24](http://docs.pointclouds.org/trunk/classpcl_1_1io_1_1_image_r_g_b24.html#details)

- class openni_wrapper::ImageYUV422(1.8版本已经取消)

[class pcl::io::ImageYUV422](http://docs.pointclouds.org/trunk/classpcl_1_1io_1_1_image_y_u_v422.html)

以上3个类分别实现了对原始数据BayerGRBG、RGB24、YUV422到图像转化接口，详细参考其父类关键函数说明。

- [class pcl::OpenNIGrabber](http://docs.pointclouds.org/trunk/classpcl_1_1_open_n_i_grabber.html)

类OpenNIGrabber实现对OpenNI设备(例如Primesense PSDK,Microsoft Kinect, Asus XTion Pro/Live)数据的采集接口，详细参考其父类Grabber关键函数说明。

- [class pcl::PCDReader](http://docs.pointclouds.org/trunk/classpcl_1_1_p_c_d_reader.html)

- [class pcl::PLYReader](http://docs.pointclouds.org/trunk/classpcl_1_1_p_l_y_reader.html)
    
以上两个类分别是PCD、PLY文件格式读人接口的实现，详细参考其父类pcl::FileReader。

- [class pcl::PCDWriter](http://docs.pointclouds.org/trunk/classpcl_1_1_p_c_d_writer.html)

- [class pcl::PLYWriter](http://docs.pointclouds.org/trunk/classpcl_1_1_p_l_y_writer.html)

以上两个类分别是PCD、PLY文件格式写出接口的实现，详细参考其父类pcl::FileWriter。

- class [pcl::PCLIOException](http://docs.pointclouds.org/trunk/classpcl_1_1io_1_1_i_o_exception.html#details)
    
类PCI_IOException是I/O相关的异常处理接口实现，详细参考其父类PCI_Exception。

## I/O模块其他关键成员函数说明
- 1
```c++
PCL_EXPORTS int pcl::io::saveOBJFile ( const std::string &     file_name,
                                       const pcl::TextureMesh &    tex_mesh,
                                       unsigned    precision = 5 
)   
```
Saves a TextureMesh(网格模型数据) in ascii OBJ format.

- 2
```c++
PCL_EXPORTS int pcl::io::saveOBJFile (   const std::string &     file_name,
                                         const pcl::PolygonMesh &    mesh,
                                         unsigned    precision = 5 
)   
```
Saves a PolygonMesh in ascii PLY format.

- 3
```c++

int pcl::io::loadPCDFile (   const std::string &     file_name,
                             pcl::PCLPointCloud2 &   cloud 
)   
```
Load a PCD v.6 file into a templated PointCloud type.

- 4
```c++
int pcl::io::loadPCDFile (   const std::string &     file_name,
                             pcl::PCLPointCloud2 &   cloud,
                             Eigen::Vector4f &   origin,
                             Eigen::Quaternionf &    orientation 
)   
```
Load any PCD file into a templated PointCloud type.

- 5
```c++
int pcl::io::loadPCDFile (   const std::string &     file_name,
                             pcl::PointCloud< PointT > &     cloud 
)   
```
Load any PCD file into a templated PointCloud type.

- 6
```c++
int pcl::io::savePCDFile (  const std::string &     file_name,
                            const pcl::PCLPointCloud2 &     cloud,
                            const Eigen::Vector4f &     origin = Eigen::Vector4f::Zero (),
                            const Eigen::Quaternionf &  orientation = Eigen::Quaternionf::Identity (),
                            const bool  binary_mode = false 
)   
```
Save point cloud data to a PCD file containing n-D points.

- 7
```c++
template<typename PointT >
int pcl::io::savePCDFile (  const std::string &     file_name,
                            const pcl::PointCloud< PointT > &   cloud,
                            bool    binary_mode = false 
)   
```
Templated version for saving point cloud data to a PCD file containing a specific given cloud format.

- 8
```c++
template<typename PointT >
int pcl::io::savePCDFileASCII (   const std::string &     file_name,
                                  const pcl::PointCloud< PointT > &   cloud 
)   
```
Templated version for saving point cloud data to a PCD file containing a specific given cloud format.
This version is to retain backwards compatibility.

- 9
```c++
template<typename PointT >
int pcl::io::savePCDFileBinary (   const std::string & file_name,
                                   const pcl::PointCloud< PointT > &   cloud 
)   
```
Templated version for saving point cloud data to a PCD file containing a specific given cloud format.
The resulting file will be an uncompressed binary.

- 10
```c++
template<typename PointT >
int pcl::io::savePCDFileBinaryCompressed (   const std::string &     file_name,
                                             const pcl::PointCloud< PointT > &   cloud 
)   
```
Templated version for saving point cloud data to a PCD file containing a specific given cloud format.
This method will write a compressed binary file.
This version is to retain backwards compatibility.

- 11
```c++
void pcl::io::throwIOException  (   const char *    function,
                                    const char *    file,
                                    unsigned    line,
                                    const char *    format,
                                ... 
)   
```
异常处理函数

- 12
```c++
template<typename PointT >
int pcl::io::loadPLYFile    (   const std::string &     file_name,
                                pcl::PointCloud< PointT > &     cloud 
)   
```
Load any PLY file into a templated PointCloud type.

- 13
```c++
int pcl::io::loadPLYFile    (   const std::string &     file_name,
                                pcl::PolygonMesh &  mesh 
)   
```
Load a PLY file into a PolygonMesh type.

- 14
```c++
template<typename PointT >
int pcl::io::savePLYFile    (   const std::string &     file_name,
                                const pcl::PointCloud< PointT > &   cloud,
                                const std::vector< int > &  indices,
                                bool    binary_mode = false 
)   
```
Templated version for saving point cloud data to a PLY file containing a specific given cloud format.

- 15
```c++
PCL_EXPORTS int pcl::io::savePLYFile    (   const std::string &     file_name,
                                            const pcl::PolygonMesh &    mesh,
                                            unsigned    precision = 5 
                                        )
```
Saves a PolygonMesh in ascii PLY format.

- 16
```c++
template<typename PointT >
int pcl::io::savePLYFileASCII   (   const std::string &     file_name,
                                    const pcl::PointCloud< PointT > &   cloud 
)   
```
Templated version for saving point cloud data to a PLY file containing a specific given cloud format.

- 17
```c++
template<typename PointT >
int pcl::io::savePLYFileBinary  (   const std::string &     file_name,
                                    const pcl::PointCloud< PointT > &   cloud 
)   
```
Templated version for saving point cloud data to a PLY file containing a specific given cloud format.

- 18
```c++
PCL_EXPORTS int pcl::io::savePLYFileBinary  (   const std::string &     file_name,
                                                const pcl::PolygonMesh &    mesh 
)   
```
Saves a PolygonMesh in binary PLY format.

- 19
```c++
PCL_EXPORTS void pcl::io::saveRgbPNGFile    (   const std::string &     file_name,
const unsigned char *   rgb_image,
int     width,
int     height 
)   
```
Saves 8-bit encoded RGB image to PNG file.

- 20
```c++
PCL_EXPORTS void pcl::io::saveShortPNGFile  (   const std::string &     file_name,
                                                const unsigned short *  short_image,
                                                int     width,
                                                int     height,
                                                int     channels 
)   
```
Saves 16-bit encoded image to PNG file.

- 21
```c++
template<typename PointT >
void pcl::io::savePNGFile   (   const std::string &     file_name,
                                const pcl::PointCloud< PointT > &   cloud,
                                const std::string &     field_name 
)   
```
Saves the data from the specified field of the point cloud as image to PNG file.

- 22
```c++
PCL_EXPORTS int pcl::io::saveVTKFile    (   const std::string &     file_name,
                                            const pcl::PolygonMesh &    triangles,
                                            unsigned    precision = 5 
)
```
Saves a PolygonMesh in ascii VTK format.

- 23
```c++
PCL_EXPORTS int pcl::io::saveVTKFile    (   const std::string &     file_name,
                                            const pcl::PCLPointCloud2 &     cloud,
                                            unsigned    precision = 5 
)   
```
Saves a PointCloud in ascii VTK format.

#应用实例解析

##PCD(点云数据)文件格式

- 1 为什么用一种新的文件格式？
    - **PLY**是一种多边形文件格式，由Stanford大学的Turk等人设计开发；
    - **STL**是3D Systems公司创建的模型文件格式，主要应用于CAD, CAM领域；
    - **OBJ**是从几何学上定义的文件格式，首先由Wavefront Technologies开发；
    - **X3D**是符合ISO标准的基于XML的文件格式，表示3D计算机图形数据；

- 2 PCD版本

用PCD_Vx来编号，代表PCD文件的0.x版本号

- 3 文件头格式
每一个PCD文件包含一个文件头，它确定和声明文件中存储的点云数据的某种特性。PCD文件头必须用ASCII码来编码。PCD文件中指定的每一个文件头字段以及ascii点数据都用一个新行(\n)分开了，从0. 7版本开始，PCD文件头包含下面的字段:
    - (1) VERSION ------ 指定PCD文件版本
    - (2) FIELDS  ------ 指定一个点可以有的每一个维度和字段的名字。例如:

        - FIELDS x y z  # XYZ data

        - FIELDS x y z rgb # XYZ + colors

        - FIELDS x y z normal_x normal_y normal_z # XYZ + surface normals

        - FIELDS j1 j2 j3 # moment invariants



    - (3) SIZE ------ 用字节数指定每一个维度的大小。例如：
    
        - unsigned char/char has 1 byte

        - unsigned short/short has 2 bytes

        - unsigned int/int/float  has 4 bytes

        - double has 8 bytes

    - (4) TYPE ------ 用一个字符指定每一个维度的类型。现在被接受的类型有：
    
        - I – 表示有符号类型int8（char）、int16（short）和int32（int)；

        - U - 表示无符号类型uint8（unsigned char）、uint16（unsigned short）和uint32（unsigned int)；

        - F - 表示浮点类型；

    - (5) COUNT ------ 指定每一个维度包含的元素数目。例如，x这个数据通常有一个元素，但是像VFH这样的特征描述子就有308个。实际上这是在给每一点引入n维直方图描述符的方法，把它们当做单个的连续存储块。默认情况下，如果没有COUNT，所有维度的数目被设置成1。

    - (6) WIDTH ------ 用点的数量表示点云数据集的宽度。根据是有序点云还是无序点云，WIDTH有两层解释：

        - 1) 它能确定无序数据集的点云中点的个数（和下面的POINTS一样）；

        - 2) 它能确定有序点云数据集的宽度（一行中点的数目）。
        
        注意：有序点云数据集，意味着点云是类似于图像（或者矩阵）的结构，数据分为行和列。这种点云的实例包括立体摄像机和时间飞行摄像机生成的数据。有序数据集的优势在于，预先了解相邻点（和像素点类似）的关系，邻域操作更加高效，这样就加速了计算并降低了PCL中某些算法的成本。

        例如：
        WIDTH 640 # 每行有640个点

    - (7) HEIGHT ------ 用点的数目表示点云数据集的高度。类似于WIDTH ，HEIGHT也有两层解释：
        - 1) 它表示有序点云数据集的高度（行的总数）；
        
        - 2) 对于无序数据集它被设置成1（被用来检查一个数据集是有序还是无序）。

        有序点云例子：

        WIDTH 640 # 像图像一样的有序结构，有640行和480列

        HEIGHT 480 # 这样该数据集中共有640*480=307200个点
        
        无序点云例子：

        WIDTH 307200

        HEIGHT 1 # 有307200个点的无序点云数据集

    - (8) VIEWPOINT ------ 指定数据集中点云的获取视点。VIEWPOINT有可能在不同坐标系之间转换的时候应用，在辅助获取其他特征时也比较有用，例如曲面法线，在判断方向一致性时，需要知道视点的方位，
    视点信息被指定为平移（txtytz）+四元数（qwqxqyqz）。默认值是：
    VIEWPOINT 0 0 0 1 0 0 0

    - (9) POINTS ------ 指定点云中点的总数。从0.7版本开始，该字段就有点多余了，因此有可能在将来的版本中将它移除。例如：
    
        POINTS 307200   #点云中点的总数为307200

    - (10) DATA ------ 指定存储点云数据的数据类型。从0.7版本开始，支持两种数据类型：ascii和二进制。查看下一节可以获得更多细节。
    注意：文件头最后一行（DATA）的下一个字节就被看成是点云的数据部分了，它会被解释为点云数据。

警告：PCD文件的文件头部分必须以上面的顺序精确指定，也就是如下顺序：VERSION、FIELDS、SIZE、TYPE、COUNT、WIDTH、HEIGHT、VIEWPOINT、POINTS、DATA之间用换行隔开。

- 4 数据存储类型

两种： ASCII 和 二进制形式

- 5 相对于其他文件格式的优势
    - (1) 存储和处理有序点云数据集的能力——这一点对于实时应用，例如增强现实、机器人学等领域十分重要；
    - (2) 二进制mmap/munmap数据类型是把数据下载和存储到磁盘上最快的方法；
    - (3) 存储不同的数据类型（支持所有的基本类型：char，short，int，float，double）——使得点云数据在存储和处理过程中适应性强并且高效，其中无效的点的通常存储为NAN类型；
    - (4) 特征描述子的n维直方图------对于3D识别和计算机视觉应用十分重要。

- 6 例子
```pcd
#.PCD v .7 - Point Cloud Data file format
VERSION .7
FIELDS x y z rgb
SIZE 4 4 4 4
TYPE F FFF
COUNT 1 1 1 1
WIDTH 213
HEIGHT 1
VIEWPOINT 0 0 0 1 0 0 0
POINTS 213
DATA ascii
0.93773 0.33763 0 4.2108e+06
0.90805 0.35641 0 4.2108e+06
```

##从PCD文件中读取点云数据 
```c++
// read from pcd
/* 头文件声明 */
#include <iostream> //标准C++库中的输入输出的头文件
#include <pcl/io/pcd_io.h> //PCD读写类相关的头文件
#include <pcl/point_types.h> //PCL中支持的点类型的头文件

int
main (int argc, char** argv)
{
    /* 创建一个PointCloud<pcl::PointXYZ>    boost共享指针并进行实例化 */
    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZ>);

    //打开点云文件
    if (pcl::io::loadPCDFile<pcl::PointXYZ>("test_pcd.pcd", *cloud) == -1) {
        PCL_ERROR("Couldn't read file test_pcd.pcd \n");
        return (-1);
  }
//默认就是二进制块读取转换为模块化的PointCLoud格式里pcl::PointXYZ作为点类型  然后打印出来
  std::cout << "Loaded "
            << cloud->width * cloud->height
            << " data points from test_pcd.pcd with the following fields: "
            << std::endl;
  for (size_t i = 0; i < cloud->points.size (); ++i)
    std::cout << "    " << cloud->points[i].x
              << " "    << cloud->points[i].y
              << " "    << cloud->points[i].z << std::endl;

  return (0);
}
```

```c++
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project(write_pcd)

find_package(PCL 1.2 REQUIRED)

include_directories(${PCL_INCLUDE_DIRS})
link_directories(${PCL_LIBRARY_DIRS})
add_definitions(${PCL_DEFINITIONS})

add_executable (write_pcd write_pcd.cpp)
target_link_libraries (write_pcd ${PCL_LIBRARIES})
```


##向PCD文件中写入点云数据

```c++
#include <iostream>              //标准C++库中的输入输出的头文件
#include <pcl/io/pcd_io.h>       //PCD读写类相关的头文件
#include <pcl/point_types.h>     //PCL中支持的点类型的头文件

int
  main (int argc, char** argv)
{
  //实例化的模板类PointCloud  每一个点的类型都设置为pcl::PointXYZ
/*************************************************
 点PointXYZ类型对应的数据结构
    Structure PointXYZ{
     float x;
     float y;
     float z;
    };
**************************************************/
  pcl::PointCloud<pcl::PointXYZ> cloud;

  // 创建点云  并设置适当的参数（width height is_dense）
  cloud.width    = 5;
  cloud.height   = 1;
  cloud.is_dense = false;  //不是稠密型的
  cloud.points.resize (cloud.width * cloud.height);  //点云总数大小
   //用随机数的值填充PointCloud点云对象 
  for (size_t i = 0; i < cloud.points.size (); ++i)
  {
    cloud.points[i].x = 1024 * rand () / (RAND_MAX + 1.0f);
    cloud.points[i].y = 1024 * rand () / (RAND_MAX + 1.0f);
    cloud.points[i].z = 1024 * rand () / (RAND_MAX + 1.0f);
  }
  //把PointCloud对象数据存储在 test_pcd.pcd文件中
  pcl::io::savePCDFileASCII ("test_pcd.pcd", cloud);
  
//打印输出存储的点云数据
  std::cerr << "Saved " << cloud.points.size () << " data points to test_pcd.pcd." << std::endl;

  for (size_t i = 0; i < cloud.points.size (); ++i)
    std::cerr << "    " << cloud.points[i].x << " " << cloud.points[i].y << " " << cloud.points[i].z << std::endl;

  return (0);
}
```

##连接两个点云中的字段或数据形成新点云
如果有两个点云如：
pcl::PointCloutd<pcl::PointXYZ> cloud_a;
pcl::PointCloutd<pcl::PointXYZ> cloud_b;
假设两个都已经初始化，则两者可以连接在一起
pcl::PointCloutd<pcl::PointXYZ> cloud_c：
cloud_c=cloud_a;
cloud_c+=cloud_b;
```c++
#include <iostream>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>

int main(int argc, char** argv)
{
    if (argc != 2) {
        std::cerr << "please specify command line arg '-f' or '-p'" << std::endl;
        exit(0);
    }
    pcl::PointCloud<pcl::PointXYZ> cloud_a, cloud_b, cloud_c;
    pcl::PointCloud<pcl::Normal> n_cloud_b; // 存储进行连接时需要的normal点云
    pcl::PointCloud<pcl::PointNormal> p_n_cloud_c; // 存储连接XYZ与normal后的点云
    // 创建点云
    cloud_a.width = 5; // 设置cloud_a 的点个数为3
    cloud_a.height = cloud_b.height = n_cloud_b.height = 1; // 设置都为无序点云
    cloud_a.points.resize(cloud_a.width * cloud_a.height);
    if (strcmp(argv[1], "-p") == 0) // 判断进行是否为连接a+b=c
    {
        cloud_b.width = 3;
        cloud_b.points.resize(cloud_b.width * cloud_b.height);
    }

    else {
        n_cloud_b.width = 5;
        n_cloud_b.points.resize(n_cloud_b.width * n_cloud_b.height);
    }
    for (size_t i = 0; i < cloud_a.points.size(); ++i) {
        cloud_a.points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
        cloud_a.points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
        cloud_a.points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
    }

    if (strcmp(argv[1], "-p") == 0)
        for (size_t i = 0; i < cloud_b.points.size(); ++i) {
            cloud_b.points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
            cloud_b.points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
            cloud_b.points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
        }
    else
        for (size_t i = 0; i < n_cloud_b.points.size(); ++i) {
            n_cloud_b.points[i].normal[0] = 1024 * rand() / (RAND_MAX + 1.0f);
            n_cloud_b.points[i].normal[1] = 1024 * rand() / (RAND_MAX + 1.0f);
            n_cloud_b.points[i].normal[2] = 1024 * rand() / (RAND_MAX + 1.0f);
        }

    std::cerr << "Cloud A: " << std::endl;
    for (size_t i = 0; i < cloud_a.points.size(); ++i)
        std::cerr << "    " << cloud_a.points[i].x << " " << cloud_a.points[i].y << " " << cloud_a.points[i].z << std::endl;

    std::cerr << "Cloud B: " << std::endl;

    if (strcmp(argv[1], "-p") == 0)
        for (size_t i = 0; i < cloud_b.points.size(); ++i)
            std::cerr << "    " << cloud_b.points[i].x << " " << cloud_b.points[i].y << " " << cloud_b.points[i].z << std::endl;
    else
        for (size_t i = 0; i < n_cloud_b.points.size(); ++i)
            std::cerr << "    " << n_cloud_b.points[i].normal[0] << " " << n_cloud_b.points[i].normal[1] << " " << n_cloud_b.points[i].normal[2] << std::endl;

    //拷贝点云数据
    if (strcmp(argv[1], "-p") == 0) {
        cloud_c = cloud_a;
        cloud_c += cloud_b;
        std::cerr << "Cloud C: " << std::endl;
        for (size_t i = 0; i < cloud_c.points.size(); ++i)
            std::cerr << "    " << cloud_c.points[i].x << " " << cloud_c.points[i].y << " " << cloud_c.points[i].z << " " << std::endl;
    } else {
        pcl::concatenateFields(cloud_a, n_cloud_b, p_n_cloud_c);
        std::cerr << "Cloud C: " << std::endl;
        for (size_t i = 0; i < p_n_cloud_c.points.size(); ++i)
            std::cerr << "    " << p_n_cloud_c.points[i].x << " " << p_n_cloud_c.points[i].y << " " << p_n_cloud_c.points[i].z << " " << p_n_cloud_c.points[i].normal[0] << " " << p_n_cloud_c.points[i].normal[1] << " " << p_n_cloud_c.points[i].normal[2] << std::endl;
    }
    return(0);
}
```

##PCL中的OpenNI点云获取框架
```c++
 #include <pcl/io/openni_grabber.h>
 #include <pcl/visualization/cloud_viewer.h>
 #ifdef _WIN32
 # define sleep(x) Sleep((x)*1000)
 #endif

 class SimpleOpenNIViewer
 {
   public:
     SimpleOpenNIViewer () : viewer ("PCL OpenNI Viewer") {} // 使用初始化列表来初始化字段
     /* 使用初始化列表来初始化字段例子 */
     /*
     Line::Line( double len): length(len)
    {
        cout << "Object is being created, length = " << len << endl;
    }
      */

     void cloud_cb_ (const pcl::PointCloud<pcl::PointXYZ>::ConstPtr &cloud)
     {
       if (!viewer.wasStopped())
         viewer.showCloud (cloud);
     }

     void run ()
     {
       pcl::Grabber* interface = new pcl::OpenNIGrabber();
       boost::function<void (const pcl::PointCloud<pcl::PointXYZ>::ConstPtr&)> f =
         boost::bind (&SimpleOpenNIViewer::cloud_cb_, this, _1);
       interface->registerCallback (f);
       interface->start ();
       while (!viewer.wasStopped())
       {
         boost::this_thread::sleep (boost::posix_time::seconds (1));
       }
       interface->stop ();
     }
     pcl::visualization::CloudViewer viewer;
 };

 int main ()
 {
   SimpleOpenNIViewer v;
   v.run ();
   return 0;
 }

```
