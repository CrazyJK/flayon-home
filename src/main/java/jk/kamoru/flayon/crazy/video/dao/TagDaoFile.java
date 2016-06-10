package jk.kamoru.flayon.crazy.video.dao;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.PostConstruct;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.springframework.stereotype.Repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.domain.video.Tag;
import lombok.extern.slf4j.Slf4j;

// TODO file dao implementation
@Slf4j
@Repository
public class TagDaoFile extends CrazyProperties implements TagDao, VIDEO {
	
	private Path tagDataPath;
	
	private List<Tag> tags;

	private ObjectMapper mapper = new ObjectMapper();

	@PostConstruct
	public void init() {
		tagDataPath = Paths.get(STORAGE_PATHS[0], TAG_DATA_FILENAME);
		log.info("load data... {}", tagDataPath);
		try {
			if (!Files.exists(tagDataPath)) {
				Files.createFile(tagDataPath);
				tags = new ArrayList<>();
				log.info("file is not exist. just make it");
			}
			else {
				tags = mapper.readValue(tagDataPath.toFile(), new TypeReference<List<Tag>>() {});
				log.info("found tags {}", tags.size());
			}
		} catch (IOException e) {
			log.error("Fail to read tag.data", e);
			throw new CrazyException("Fail to read tag.data", e);
		}
	}

	private Integer findMaxId() {
		int[] array = new int[tags.size()];
		int i = 0;
		for (Tag tag : tags) {
			array[i++] = tag.getId();
		}
		return (int)NumberUtils.max(array);
	}
	
	@Override
	public Tag persist(Tag tag) {
		tag.setId(findMaxId() + 1);
		tags.add(tag);
		try {
			mapper.writeValue(tagDataPath.toFile(), tags);
		} catch (IOException e) {
			throw new CrazyException("Fail to write tag.data", e);
		}
		return tag;
	}

	@Override
	public Tag findById(Integer id) throws CrazyException {
		for (Tag tag : tags) {
			if (tag.getId() == id)
				return tag;
		}
		throw new CrazyException("not found tag by id:" + id);
	}

	@Override
	public Tag findByName(String name) throws CrazyException {
		for (Tag tag : tags) {
			if (StringUtils.equals(tag.getName(), name))
				return tag;
		}
		throw new CrazyException("not found tag by name:" + name);
	}

	@Override
	public List<Tag> findByDesc(String desc) {
		List<Tag> found = new ArrayList<>();
		for (Tag tag : tags) {
			if (StringUtils.containsIgnoreCase(tag.getDescription(), desc))
				found.add(tag);
		}
		return found;
	}

	@Override
	public List<Tag> findAll() {
		return tags;
	}

	@Override
	public void merge(Tag updateTag) {
		for (Tag tag : tags) {
			if (tag.getId() == updateTag.getId()) {
				
// TODO				tag.update(updateTag);
				break;
			}
		}
	}

	@Override
	public void remove(Tag tag) {
		// TODO
		
		
	}

}
