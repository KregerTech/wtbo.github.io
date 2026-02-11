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

public class TextScript extends Object
{
   private Graphics gc;
   private ParamParser param;

   private FontMetrics fm;
   private Font fontPlain;
   private Font fontItalic;
   private String fontName;
   private int fontSize;

   private Dimension size;
   private long last;

   private int number;
   private int bWidth;
   private int bHeight;
   private int space;

   private Random random;
   private boolean randomOrder = false;

   private TextQuote quote;
   private Vector current;
   private Vector discard;

   TextScript(Graphics gc, ParamParser param, Dimension size)
   {
      this.param = param;
      this.size = size;
      this.gc = gc;
   }

   public void init()
   {
      bWidth = param.parseInt("bwidth", 10);
      bHeight = param.parseInt("bheight", 10);
      space = param.parseInt("space", 20);

      randomOrder = param.parseBoolean("random", false);
      random = new Random(System.currentTimeMillis());

      current = new Vector(0, 1);
      discard = new Vector(0, 1);

      fontSize = param.parseInt("fontsize", 10);
      fontName = param.parseString("fontname", "TimesRoman");
      fontPlain = new Font(fontName, Font.PLAIN, fontSize);
      fontItalic = new Font(fontName, Font.ITALIC, fontSize);
      fm = gc.getFontMetrics(fontPlain);

      number = param.parseInt("number", 0);

      // Read in the quotes.

      for (int i = 0; i < number; i++)
      {
         String[] s = param.parseStrings("quote" + i, "|", 5);

         if (s != null)
         {
            String[] q = param.parser.wordWrap(s[0], fm,
                                               size.width - (2 * bWidth));

            Color fg = new Color(Integer.parseInt(s[2], 16));
            Color bg = new Color(Integer.parseInt(s[3], 16));
            int l = Integer.parseInt(s[4]);

            current.insertElementAt(new TextQuote(q, s[1], l, fg, bg), i);
         }
      }

      current.trimToSize();
   }

   public void start()
   {
      quote = getQuote(null);
      last = System.currentTimeMillis();
   }

   private TextQuote getQuote(TextQuote old)
   {
      TextQuote rv = null;

      // Discard the old quote.

      if (old != null)
      {
         discard.addElement(old);
      }

      // Return the next quote in the current list.

      if (!randomOrder)
      {
         rv = (TextQuote) (current.elementAt(0));
         current.removeElementAt(0);
      }

      // Return a quote randomly from the current list.

      else
      {
         int index = (int) (random.nextFloat() * (current.size() - 1));
         rv = (TextQuote) (current.elementAt(index));
         current.removeElementAt(index);
      }

      // Set current to discard list, and allocate a new discard list.

      if (current.isEmpty())
      {
         current = discard;
         discard = new Vector(0, 1);
      }

      return rv;
   }

   public void update()
   {
      long time = System.currentTimeMillis();

      if ((time - last) >= quote.length)
      {
         last = time;
         quote = getQuote(quote);
      }
   }

   public void paint(Graphics g)
   {
      if (quote != null)
      {
         int x = bWidth;
         int y = bHeight;

         int ascent = fm.getAscent();
         int height = fm.getHeight();

         g.setColor(quote.bgColor);
         g.fillRect(0, 0, size.width, size.height);

         g.setColor(quote.fgColor);
         g.setFont(fontPlain);

         for (int i = 0; i < quote.text.length; i++)
         {
            g.drawString(quote.text[i], x, y + ascent);
            y += height;
         }

         g.setFont(fontItalic);
         g.drawString(quote.company, x + 10, y + space);
      }
   }

   public void stop()
   {
   }
}
