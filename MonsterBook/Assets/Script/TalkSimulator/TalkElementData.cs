using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "TalkElementData", menuName = "TalkSimulator/TalkElementData")]
public class TalkElementData : ScriptableObject
{
    public enum ElementType
    {
        Talk,
        RemoveCharacter,
    }

    public enum CharacterStandAnchorType
    {
        Left,
        Right,
    }

    [SerializeField]
    private int index;
    public int Index { get { return index; } }

    [SerializeField]
    private ElementType type;
    public ElementType Type { get { return type; } }

    [SerializeField]
    private string characterName;
    public string CharacterName { get { return characterName; } }

    [TextArea]
    [SerializeField]
    private string talk;
    public string Talk { get { return talk; } }

    [SerializeField]
    private Sprite character;
    public Sprite Character { get { return character; } }

    [SerializeField]
    private CharacterStandAnchorType characterStandAnchor;
    public CharacterStandAnchorType CharacterStandAnchor { get { return characterStandAnchor; } }



}
