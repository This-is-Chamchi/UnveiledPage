using UnityEngine;
using Sirenix.OdinInspector;

#if UNITY_EDITOR
[CreateAssetMenu(fileName = "UIColorData", menuName = "UI/UIColorData", order = 0)]
public class UIColorData : SerializedScriptableObject
{
    [SerializeField]
    public SerializableDictionary<string, Color> colorDic = new SerializableDictionary<string, Color>();

}

#endif
