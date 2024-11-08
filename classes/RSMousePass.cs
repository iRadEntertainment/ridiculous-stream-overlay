using Godot;
using System;
using System.Runtime.InteropServices;

public partial class RSMousePass : Node
{
	// GetActiveWindow() retrieves the handle of the currently active window on the desktop.
	[DllImport("user32.dll")]
	public static extern IntPtr GetActiveWindow();

	//  SetWindowLong() modifies a specific flag value associated with a window.
	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);

	private const int GwlExStyle = -20;

	// "Properties" of the window to be set, Layered is to have transparent pixels, Transparent is to make the window click-through
	private const uint WsExLayered = 0x00080000;
	private const uint WsExTransparent = 0x00000020;

	// index reference of the window
	private IntPtr _hWnd;

	private bool _platformSupported;

	public override void _Ready()
	{
		_platformSupported = OS.GetName() == "Windows";
		if (!_platformSupported)
		{
			return;
		}

		// Get the reference of the game window
		_hWnd = GetActiveWindow();

		// setting the flags of becoming a layered and transparent window
		// SetWindowLong(_hWnd, GwlExStyle, WsExLayered | WsExTransparent);
		SetWindowLong(_hWnd, GwlExStyle, WsExLayered);
	}

	// Call this method via your preferred detection algorythm (personally I check the
	// pixel under cursor to have alpha < 0.5f but you do you)
	public void SetClickThrough(bool clickthrough)
	{
		if (!_platformSupported)
		{
			return;
		}

		if (clickthrough)
		{
			SetWindowLong(_hWnd, GwlExStyle, WsExLayered | WsExTransparent);
		}
		else
		{
			SetWindowLong(_hWnd, GwlExStyle, WsExLayered);
		}
	}
}
