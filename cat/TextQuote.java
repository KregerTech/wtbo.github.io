/*
* Copyright (c) 1994-1998 Sun Microsystems, Inc. All Rights Reserved.
*
* Permission to use, copy, modify, and distribute this software and its
* documentation for NON-COMMERCIAL or COMMERCIAL purposes and without fee is
* hereby granted. Please refer to the file
* http://java.sun.com/nav/business/trademark_guidelines.html for further
* important copyright and trademark information and to
* http://java.sun.com/nav/business/index.html for further important licensing
* information for the Java (tm) Technology.
* 
* SUN MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE
* SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
* IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR
* NON-INFRINGEMENT. SUN SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY
* LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR
* ITS DERIVATIVES.
* 
* THIS SOFTWARE IS NOT DESIGNED OR INTENDED FOR USE OR RESALE AS ON-LINE
* CONTROL EQUIPMENT IN HAZARDOUS ENVIRONMENTS REQUIRING FAIL-SAFE PERFORMANCE,
* SUCH AS IN THE OPERATION OF NUCLEAR FACILITIES, AIRCRAFT NAVIGATION OR
* COMMUNICATION SYSTEMS, AIR TRAFFIC CONTROL, DIRECT LIFE SUPPORT MACHINES, OR
* WEAPONS SYSTEMS, IN WHICH THE FAILURE OF THE SOFTWARE COULD LEAD DIRECTLY TO
* DEATH, PERSONAL INJURY, OR SEVERE PHYSICAL OR ENVIRONMENTAL DAMAGE ("HIGH
* RISK ACTIVITIES"). SUN SPECIFICALLY DISCLAIMS ANY EXPRESS OR IMPLIED
* WARRANTY OF FITNESS FOR HIGH RISK ACTIVITIES.
*/

import java.awt.*;
import java.util.*;

public class TextQuote extends Object
{
   public String[] text;
   public String company;
   public long length;
   public Color fgColor;
   public Color bgColor;

   TextQuote(String[] t, String c, int len, Color fg, Color bg)
   {
      text = t;
      company = c;
      length = len * 1000;
      fgColor = fg;
      bgColor = bg;
   }
}
