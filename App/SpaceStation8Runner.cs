//
// Copyright (c) Jesse Freeman, Pixel Vision 8. All rights reserved.
//
// Licensed under the Microsoft Public License (MS-PL) except for a few
// portions of the code. See LICENSE file in the project root for full
// license information. Third-party libraries used by Pixel Vision 8 are
// under their own licenses. Please refer to those libraries for details
// on the license they use.
//
// Contributors
// --------------------------------------------------------
// This is the official list of Pixel Vision 8 contributors:
//
// Jesse Freeman - @JesseFreeman
// Christina-Antoinette Neofotistou @CastPixel
// Christer Kaitila - @McFunkypants
// Pedro Medeiros - @saint11
// Shawn Rakowski - @shwany
// Drake Williams - drakewill+pv8@gmail.com
//

using System;
using System.Collections.Generic;
using PixelVision8.Player;
using System.IO;
using System.Linq;
using Microsoft.Xna.Framework;

namespace PixelVision8.Runner
{

    /// <summary>
    ///     This is the main type for your game.
    /// </summary>
    public class SpaceStation8Runner : DesktopRunner
    {

        public SpaceStation8Runner(string rootPath, string[] args = null): base(rootPath, args)
        {
        }

        public override void OnFileDropped(object gameWindow, string path)
        {

            if(path.EndsWith(".png"))
            {
                Console.WriteLine("Load from " + path);

                var colors = ActiveEngine.ColorChip.HexColors;

                ReadImage(path, ActiveEngine.GameChip.Color(2));
            }
            
            
        }

        public void ReadImage(string path, string maskHex = Constants.MaskColor, string[] colorRefs = null)
        {
            
            PNGReader reader = null;

            using (var memoryStream = new MemoryStream(File.ReadAllBytes(path)))
            {
                // using (var fileStream = workspace.OpenFile(File.ReadAllBytes(file), FileAccess.Read))
                // {
                //     fileStream.CopyTo(memoryStream);
                //     fileStream.Close();
                // }

                reader = new PNGReader(memoryStream.ToArray());
            }

            var tmpColorChip = new ColorChip();


            var imageParser = new SpriteImageParser("", reader, tmpColorChip);

            // Manually call each step
            imageParser.ParseImageData();

            List<string> finalColors; 

            // If no colors are passed in, used the image's palette
            if (colorRefs == null)
            {
                finalColors = reader.ColorPalette.Select(c => c.ToString()).ToList();
            }
            else
            {
                finalColors = colorRefs.ToList();
            }

            if(finalColors.IndexOf(maskHex) > -1)
                finalColors.RemoveAt(finalColors.IndexOf(maskHex));

            finalColors.Insert(0, maskHex);

            // Resize the color chip
            tmpColorChip.Total = finalColors.Count;

            // Add the colors
            for (int i = 0; i < finalColors.Count; i++)
            {
                tmpColorChip.UpdateColorAt(i, finalColors[i]);
            }

            // Parse the image with the new colors
            imageParser.CreateImage();

            // Push the image into PV8
            var LuaScript = ((LuaGameChip)ActiveEngine.GameChip).LuaScript;

            if (LuaScript?.Globals["OnLoadImage"] == null) return;

            LuaScript.Call(LuaScript.Globals["OnLoadImage"], imageParser.ImageData);
        }

        protected override void Update(GameTime gameTime)
        {

            base.Update(gameTime);

            // Force the game to render in the background
            if(RunnerActive == false)
            {
                TimeDelta = (int) (gameTime.ElapsedGameTime.TotalSeconds * 1000);
                ActiveEngine.Update(TimeDelta);
            }
        }

        protected override void Draw(GameTime gameTime)
        {
        
            base.Draw(gameTime);
            
            // Only call draw if the window has focus
            if (RunnerActive == false) ActiveEngine.Draw();

        }

        public override void Back(Dictionary<string, string> metaData = null)
        {
            // if (loadHistory.Count > 0)
            //     try
            //     {
            //         // Remvoe the last game that was running from the history
            //         loadHistory.RemoveAt(loadHistory.Count - 1);

            //         // Get the previous game
            //         var lastGameRef = loadHistory.Last();

            //         // Copy the new meta data over to the last game ref before passing in
            //         if (metaData != null)
            //             foreach (var key in metaData.Keys)
            //                 if (lastGameRef.Value.ContainsKey(key))
            //                     lastGameRef.Value[key] = metaData[key];
            //                 else
            //                     lastGameRef.Value.Add(key, metaData[key]);

            //         // Remove that game from history since we are about to load it
            //         loadHistory.RemoveAt(loadHistory.Count - 1);

            //         // Load the last game
            //         Load(lastGameRef.Key, RunnerMode.Loading, lastGameRef.Value);

            //         return;
            //     }
            //     catch
            //     {
            //         // ignored
            //     }

            // // Make sure all disks are ejected
            // workspaceServicePlus.EjectAll();

            // AutoLoadDefaultGame();
        }

    }
}