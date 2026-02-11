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
import java.applet.*;
import java.net.*;

public class JavaQuote extends Applet implements Runnable
{
   private Dimension size;
   private Image offImage;
   private Graphics offG;
   private ParamParser param;
   private Color bgcolor;
   private Thread animate;
   private long delay;
   private String link;
   private String target;
   private TextScript script;

   public void init()
   {
      size = size();

      param = new ParamParser(this);
      bgcolor = param.parseColor("bgcolor", Color.white);
      setBackground(bgcolor);

      delay = param.parseInt("delay", 100);
      link = param.parseString("link", null);
      target = param.parseString("target", "_self");

      // Create the offImage for double-buffering.

      offImage = createImage(size.width, size.height);
      offG = offImage.getGraphics();

      // Create and initialize the script.

      script = new TextScript(offG, param, size);
      script.init();
   }

   public void start()
   {
      if ((animate == null) || (!animate.isAlive()))
      {
         animate = new Thread(this);
      }

      animate.start();
      script.start();
   }

   public void run()
   {
      while (Thread.currentThread() == animate)
      {
         try
         {
            script.update();
            repaint();
 
            Thread.sleep(delay);
         }
 
         catch(InterruptedException e)
         {
            e.printStackTrace();
         }
      }
   }

   public void stop()
   {
      if ((animate != null) && (animate.isAlive()))
      {
         script.stop();
         animate.stop();
      }
   }

   public void destroy()
   {
      animate = null;
   }

   public void update(Graphics g)
   {
      script.paint(offG);
      paint(g);
   }

   public void paint(Graphics g)
   {
      g.drawImage(offImage, 0, 0, this);
   }

   public boolean mouseDown(Event evt, int x, int y)
   {
      if (link != null)
      {
         try
         {
            URL url = new URL(getDocumentBase(), link);
            getAppletContext().showDocument(url, target);

            if (target.equals("_self"))
            {
               stop();
            }
         }
 
         catch(MalformedURLException e)
         {
            e.printStackTrace();
         }
      }
 
      return(true);
   }

   public boolean mouseEnter(Event evt, int x, int y)
   {
      if (link != null)
      {
         showStatus(link);
      }

      return(true);
   }

   public boolean mouseExit(Event evt, int x, int y)
   {
      if (link != null)
      {
         showStatus("");
      }

      return(true);
   }
}
