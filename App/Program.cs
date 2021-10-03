using System;
using System.IO;
using System.Reflection;

namespace PixelVision8.Runner
{
    public static class Program
    {
        [STAThread]
        public static void Main(string[] args)
        {
            var root = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Content");
            
            Console.WriteLine("Program Loaded");
            using (var game = new SpaceStation8Runner(root, args))
            {
                game.Run();
            }
            
        }

    }
}