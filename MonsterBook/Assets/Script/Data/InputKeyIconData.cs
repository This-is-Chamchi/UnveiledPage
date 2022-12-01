using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

[CreateAssetMenu(fileName = "InputKeyIconData", menuName = "UI/KeySetting", order = 0)]
public class InputKeyIconData : ScriptableObject
{
    [SerializeField]
    private TMP_SpriteAsset joyStickAsset;
    public TMP_SpriteAsset JoyStickAsset { get { return joyStickAsset; } }

    [SerializeField]
    private TMP_SpriteAsset keyboardAsset;
    public TMP_SpriteAsset KeyboardAsset { get { return keyboardAsset; } }
}
