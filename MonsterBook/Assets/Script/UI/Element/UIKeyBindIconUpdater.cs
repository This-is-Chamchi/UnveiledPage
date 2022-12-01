using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class UIKeyBindIconUpdater : MonoBehaviour
{
    private TextMeshProUGUI textMeshPro;

    [SerializeField]
    private InputKeyIconData inputKeyIconData;

    private void Awake()
    {
        textMeshPro = GetComponent<TextMeshProUGUI>();
        UpdateAsset();
    }

    private void UpdateAsset()
    {
        switch (GameManager.Instance.gameInputType)
        {
            case GameInputType.Keyboard:
                textMeshPro.spriteAsset = inputKeyIconData.KeyboardAsset;
                break;
            case GameInputType.Controller:
                textMeshPro.spriteAsset = inputKeyIconData.JoyStickAsset;
                break;
        }
    }

}
